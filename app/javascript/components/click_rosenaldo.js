const clickRosenaldo = () => {
  const footer = document.querySelector('.page-footer');
  const rosenaldo = document.querySelector('.rosenaldo');

  rosenaldo.onclick = function () {
    footer.classList.add('page-footer-on-click');
  };

  rosenaldo.addEventListener('change', nightClub);
  function nightClub() {
    footer.classList.add('page-footer-on-click');
  };



};

export { clickRosenaldo };
