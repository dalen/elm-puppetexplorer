import Elm from './Main.elm';

const mountNode = document.getElementById('main');

fetch('/config.json').then(res => res.json()).then(out => {
  const app = Elm.Main.embed(mountNode, out);
  document.addEventListener('scroll', event => {
    const scroll = window.innerHeight + window.scrollY;
    if (scroll == document.body.scrollHeight && window.scrollY > 0) {
      app.ports.scrollBottom.send(scroll);
    }
  });
});
