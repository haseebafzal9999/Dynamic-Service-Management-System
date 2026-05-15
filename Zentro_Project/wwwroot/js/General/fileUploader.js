class FileUploader {
    constructor(fileUpload, imageHolder, profilePic = false, errorContainer = '', removeBtn = null, canvasWidth = 150, canvasHeight = 150) {
        this.fileUpload = document.getElementById(fileUpload);
        this.imageHolder = document.querySelector(imageHolder);
        this.profilePic = profilePic;
        this.errorContainer = document.querySelector(errorContainer);
        this.removeBtn = removeBtn ? document.querySelector(removeBtn) : null;
        this.fileAllowance = profilePic ? 1 : 12;
        this.allowedExtensions = profilePic ? ['jpg', 'png', 'webp', 'gif', 'svg'] : ['jpg', 'png', 'svg', 'webp', 'docx', 'doc', 'pdf', 'xls', 'xlsx', 'txt','csv', 'heif', 'heic'];
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight; 
        this.fileUpload.onchange = this.handleFileChange.bind(this);
    }

    handleFileChange(event) {
        const files = this.fileUpload.files;
        this.errorContainer.textContent = '';

        if (files.length === 0) return;

        const ext = files[0].name.split('.').pop().toLowerCase();
        const totalSize = Array.from(files).reduce((sum, file) => sum + file.size, 0);

        if (totalSize > 15728640) {
            this.displayError(" Please upload a smaller file");
            this.fileUpload.value = "";
            return;
        }

        if (!this.allowedExtensions.includes(ext)) {
            this.displayError(' This file type is not allowed');
            this.fileUpload.value = '';
            return;
        }

        if (files.length > this.fileAllowance) {
            this.displayError(`Maximum of ${this.fileAllowance} files can be uploaded at a time`);
            this.fileUpload.value = "";
            return;
        }

        if (this.profilePic) {
            this.displayProfilePicture(files[0]);
        } else {
            this.displayFileList(files);
        }
    }

    displayProfilePicture(file) {
        const imgElement = new Image();
        imgElement.onload = () => {
            if (imgElement.naturalWidth < 200 || imgElement.naturalHeight < 200) {
                this.displayError("Please upload an image with dimensions of at least 200x200 pixels.");
                return;
            }
            const canvas = document.createElement('canvas');
            canvas.width = this.canvasWidth; 
            canvas.height = this.canvasHeight; 
            const ctx = canvas.getContext('2d');

            const scale = Math.min(this.canvasWidth / imgElement.width, this.canvasHeight / imgElement.height);
            const newWidth = imgElement.width * scale;
            const newHeight = imgElement.height * scale;
            const offsetX = (this.canvasWidth - newWidth) / 2;
            const offsetY = (this.canvasHeight - newHeight) / 2;

            ctx.drawImage(imgElement, offsetX, offsetY, newWidth, newHeight);
            this.imageHolder.innerHTML = '';
            this.imageHolder.appendChild(canvas);
            this.imageHolder.style.backgroundImage = 'none';

            if (this.removeBtn) {
                this.removeBtn.style.display = 'block';
                this.removeBtn.onclick = () => this.clearProfilePicture();
            }
        };

        imgElement.src = URL.createObjectURL(file);
    }

    clearProfilePicture() {
        this.fileUpload.value = "";
        this.imageHolder.innerHTML = 'Upload a Photo<br>200x200';
        this.imageHolder.style.backgroundImage = 'none';
        this.removeBtn.style.display = 'none';
    }

    displayFileList(fileList) {
        const output = document.querySelector('[data-filelist]');
        let children = "";
        $(this.imageHolder).css('display', 'none');
        Array.from(fileList).forEach((file, index) => {
            children += `<div><ul><li><span class="fileName text-[14px]"> ${file.name} <span class="cross itemCross" data-id=${index}> &#9587;</span></span></li></ul></div>`;
        });
        output.innerHTML = children;

        document.querySelectorAll(".cross").forEach(cross => {
            cross.onclick = (e) => this.removeFile(e, fileList);
        });
    }

    removeFile(event, fileList) {
        const newFileList = new DataTransfer();
        Array.from(fileList).forEach((file, index) => {
            if (parseInt(event.target.dataset.id) !== index) newFileList.items.add(file);
        });

        if (newFileList.files.length === 0) {
            this.fileUpload.value = "";
            $(this.imageHolder).css('display', 'flex');
            $('.polaris-form-field-upload-wrapper').css('display', 'flex');
            document.querySelector('[data-filelist]').innerHTML = "";
        } else {
            this.displayFileList(newFileList.files);
        }
    }

    displayError(message) {
        this.errorContainer.textContent = message;
    }
}