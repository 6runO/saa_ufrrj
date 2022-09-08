const toggleAverages = () => {
  const checkCurso = document.getElementById('media-curso');
  const checkGeral = document.getElementById('media-geral');

  const averagesCurso = document.getElementsByClassName('index-data-curso');
  const averagesGeral = document.getElementsByClassName('index-data-geral');

  const totalCurso = document.getElementsByClassName('total-curso');
  const totalGeral = document.getElementsByClassName('total-geral');

  checkCurso.onclick = function () {
    if (checkCurso.checked) {
      for (let i = 0; i < averagesCurso.length; i++) {
        averagesCurso[i].classList.remove("index-data-curso-off");
        averagesCurso[i].classList.add("index-data-curso-on");
      };
      for (let i = 0; i < totalCurso.length; i++) {
        totalCurso[i].classList.remove("total-curso-off");
        totalCurso[i].classList.add("total-curso-on");
      };
    } else {
      for (let i = 0; i < averagesCurso.length; i++) {
        averagesCurso[i].classList.remove("index-data-curso-on");
        averagesCurso[i].classList.add("index-data-curso-off");
      };
      for (let i = 0; i < totalCurso.length; i++) {
        totalCurso[i].classList.remove("total-curso-on");
        totalCurso[i].classList.add("total-curso-off");
      };
    };
  };

  checkGeral.onclick = function () {
    if (checkGeral.checked) {
      for (let i = 0; i < averagesGeral.length; i++) {
        averagesGeral[i].classList.remove("index-data-geral-off");
        averagesGeral[i].classList.add("index-data-geral-on");
      };
      for (let i = 0; i < totalCurso.length; i++) {
        totalGeral[i].classList.remove("total-geral-off");
        totalGeral[i].classList.add("total-geral-on");
      };
    } else {
      for (let i = 0; i < averagesGeral.length; i++) {
        averagesGeral[i].classList.remove("index-data-geral-on");
        averagesGeral[i].classList.add("index-data-geral-off");
      };
      for (let i = 0; i < totalCurso.length; i++) {
        totalGeral[i].classList.remove("total-geral-on");
        totalGeral[i].classList.add("total-geral-off");
      };
    };
  };
};

export { toggleAverages };
