import "bootstrap";

// click on choose file when clicking on the camera icon
const pictureIcon = document.querySelector(".picture-frame");
pictureIcon.addEventListener("click", (event) => {
  document.querySelector(".picture").click();
});

// display thumbnail preview
const camera = document.querySelector(".fa-camera");
const photoCachee = document.querySelector(".picture");
photoCachee.addEventListener("change", (event) => {
    const img = document.getElementById("img_prev");
    const titleOption = document.querySelector(".thumbnail");
    img.classList.remove("hidden");
    titleOption.classList.add("title-option-preview");
    let reader = new FileReader();
    reader.onload = function (e) {
        $("#img_prev").attr('src', e.target.result);
      }
      reader.readAsDataURL(photoCachee.files[0]);
      camera.classList.add("hidden");
  });
