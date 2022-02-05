const toggleAverages = () => {
  const checkCurso = document.getElementById('media-curso');
  const checkGeral = document.getElementById('media-geral');

  const averagesCurso = document.getElementsByClassName('index-data-curso');
  const averagesGeral = document.getElementsByClassName('index-data-geral');

  checkCurso.onclick = function () {
    if (checkCurso.checked) {
      for (let i = 0; i < averagesCurso.length; i++) {
        averagesCurso[i].classList.remove("index-data-curso-off");
        averagesCurso[i].classList.add("index-data-curso-on");
      };
    } else {
      for (let i = 0; i < averagesCurso.length; i++) {
        averagesCurso[i].classList.remove("index-data-curso-on");
        averagesCurso[i].classList.add("index-data-curso-off");
      };
    };
  };

  checkGeral.onclick = function () {
    if (checkGeral.checked) {
      for (let i = 0; i < averagesGeral.length; i++) {
        averagesGeral[i].classList.remove("index-data-geral-off");
        averagesGeral[i].classList.add("index-data-geral-on");
      };
    } else {
      for (let i = 0; i < averagesGeral.length; i++) {
        averagesGeral[i].classList.remove("index-data-geral-on");
        averagesGeral[i].classList.add("index-data-geral-off");
      };
    };
  };
};

export { toggleAverages };
