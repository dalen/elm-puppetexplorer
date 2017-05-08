import Elm from './Main.elm';

const mountNode = document.getElementById('main');

fetch('/config.json')
  .then(res => res.json())
  .then(out => Elm.Main.embed(mountNode, out));
