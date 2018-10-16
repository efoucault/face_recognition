class RecognitionsController < ApplicationController
  def index
    @recognitions = Recognition.all
  end

  def show
    @recognition = Recognition.find(params[:id])
  end

  def new
    @recognition = Recognition.new
  end

  def create
    @recognition = Recognition.new(recognition_params)
    # detect a face in the picture
    puts("detect")
    require 'net/http'
    require 'json'
    uri = URI('https://northeurope.api.cognitive.microsoft.com/face/v1.0/detect')
    uri.query = URI.encode_www_form({})
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/octet-stream'
    request['Ocp-Apim-Subscription-Key'] = ENV["MS_KEY"]
    request.body = @recognition.photo.read
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    face_id = JSON.parse(response.body)[0]["faceId"]
    puts face_id

    # identify if the face_id is recognized
    puts("identify")
    uri2 = URI('https://northeurope.api.cognitive.microsoft.com/face/v1.0/identify')
    uri2.query = URI.encode_www_form({})
    request = Net::HTTP::Post.new(uri2.request_uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ENV["MS_KEY"]
    request.body = "{\"personGroupId\":\"twelvers\",\"faceIds\": [\""+ face_id +"\"],\"maxNumOfCandidatesReturned\": 1, \"confidenceThreshold\": 0.5}"
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    candidat_id = JSON.parse(response.body)[0]["candidates"][0]["personId"]
    puts candidat_id

    # get the person recognized
    puts("get person")
    uri3 = URI("https://northeurope.api.cognitive.microsoft.com/face/v1.0/persongroups/twelvers/persons/" + candidat_id)
    req = Net::HTTP::Get.new(uri3)
    req['Ocp-Apim-Subscription-Key'] = ENV["MS_KEY"]
    res = Net::HTTP.start(uri3.host, uri3.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end
    @recognition.nom = JSON.parse(res.body)["name"]

    @recognition.save!
    redirect_to recognition_path(@recognition)
  end

  private

  def recognition_params
    params.require(:recognition).permit(:nom, :photo)
  end
end
