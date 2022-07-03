document.addEventListener('turbolinks:load', () => {
  const footer = document.querySelector('.page-footer');
  const rosenaldo = document.querySelector('.rosenaldo');

  rosenaldo.addEventListener('click', nightClub);

  function nightClub() {
    footer.classList.add('footer-on-rosenaldo-click');
    rosenaldo.classList.add('rosenaldo-on-click');

    setTimeout(function () {
      footer.classList.remove('footer-on-rosenaldo-click');
      rosenaldo.classList.remove('rosenaldo-on-click');
    }, 11000);
  };
});
