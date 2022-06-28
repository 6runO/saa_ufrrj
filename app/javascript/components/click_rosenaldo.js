const clickRosenaldo = () => {
  const footer = document.querySelector('.page-footer');
  const rosenaldo = document.querySelector('.rosenaldo');

  rosenaldo.onclick = function () {
    rosenaldo.classList.add('page-footer-on-click');
  };



};

export { clickRosenaldo };
