const uploadForm = () => {
  const input = document.querySelector('.upload-input');
  const preview = document.querySelector('.preview');
  const submitBtn = document.querySelector('.btn-analisar');

  input.addEventListener('change', updateImageDisplay);

  function updateImageDisplay() {
    while (preview.firstChild) {
      preview.removeChild(preview.firstChild);
    };

    const curFiles = input.files;
    const file = curFiles[0]
    const para = document.createElement('p');

    if (curFiles.length === 0) {
      para.textContent = 'Nenhum arquivo selecionado.';
      preview.appendChild(para);
      submitBtn.classList.remove('btn-shown');
      submitBtn.classList.add('btn-hidden');
    } else if (invalidFileType(file)) {
      para.textContent = `O tipo do arquivo selecionado não é válido.`;
      preview.appendChild(para);
      submitBtn.classList.remove('btn-shown');
      submitBtn.classList.add('btn-hidden');
    } else if ((file.size / 1048576) > 2) {
      para.textContent = `O arquivo selecionado excede o tamanho máximo permitido (2MB).`;
      preview.appendChild(para);
      submitBtn.classList.remove('btn-shown');
      submitBtn.classList.add('btn-hidden');
    } else {
      para.textContent = file.name;
      preview.appendChild(para);
      submitBtn.classList.remove('btn-hidden');
      submitBtn.classList.add('btn-shown');
    };
  };

  function invalidFileType(file) {
    return file.type !== "application/pdf";
  }

  function returnFileSize(number) {
    if (number < 1024) {
      return number + 'bytes';
    } else if (number >= 1024 && number < 1048576) {
      return (number / 1024).toFixed(1) + 'KB';
    } else if (number >= 1048576) {
      return (number / 1048576).toFixed(1) + 'MB';
    };
  };
};

export { uploadForm };
