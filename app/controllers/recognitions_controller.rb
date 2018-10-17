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
    # detect faces in the picture
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
    face_array = []
    length = JSON.parse(response.body).length
    i = 0;
    while i < length
      face_id = JSON.parse(response.body)[i]["faceId"]
      face_array.push(face_id)
      i += 1
    end

    # if there is at least one face in the face array call identify for each faceS
    candidats = []
    face_array.each_with_index do |face, index|
      puts("identify")
      puts (face)
      uri2 = URI('https://northeurope.api.cognitive.microsoft.com/face/v1.0/identify')
      uri2.query = URI.encode_www_form({})
      request = Net::HTTP::Post.new(uri2.request_uri)
      request['Content-Type'] = 'application/json'
      request['Ocp-Apim-Subscription-Key'] = ENV["MS_KEY"]
      request.body = "{\"personGroupId\":\"twelvers\",\"faceIds\": [\""+ face +"\"],\"maxNumOfCandidatesReturned\": 1, \"confidenceThreshold\": 0.5}"
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(request)
      end
      if JSON.parse(response.body)[0]["candidates"][0].present?
        candidat_id = JSON.parse(response.body)[0]["candidates"][0]["personId"]
        puts candidat_id
        puts("get person")
        uri3 = URI("https://northeurope.api.cognitive.microsoft.com/face/v1.0/persongroups/twelvers/persons/" + candidat_id)
        req = Net::HTTP::Get.new(uri3)
        req['Ocp-Apim-Subscription-Key'] = ENV["MS_KEY"]
        res = Net::HTTP.start(uri3.host, uri3.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(req)
        end
        candidats.push(JSON.parse(res.body)["name"])
      end
    end
    # renseigner le nom de la recognition (soit la ou les personne reconnues, soit non reconnue)
    if candidats.present?
      @recognition.nom = candidats.join
    else
      @recognition.nom = "Je ne te connais pas"
    end
    # get the person recognized

    @recognition.save!
    redirect_to recognition_path(@recognition)
  end

  private

  def recognition_params
    params.require(:recognition).permit(:nom, :photo)
  end
end
