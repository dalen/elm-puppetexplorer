import Elm from './Main.elm';

const mountNode = document.getElementById('main');

fetch('/config.json').then(res => res.json()).then(out => {
  const app = Elm.Main.embed(mountNode, out);

  // Hack to add event listener to Elm-Mdl main element
  const addScrollListener = () => {
    const mainElem = document.getElementById('elm-mdl-layout-main');
    if (mainElem) {
      mainElem.addEventListener('scroll', event => {
        if (
          mainElem.scrollHeight - mainElem.scrollTop ===
          mainElem.clientHeight
        ) {
          app.ports.scrollBottom.send(
            mainElem.scrollHeight - mainElem.scrollTop
          );
        }
      });
    } else {
      window.setTimeout(addScrollListener, 100);
    }
  };
  addScrollListener();
});
