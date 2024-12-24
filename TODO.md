# To Do List

- [x] figure out how to get ALL of the latex from treesitter - currently only gets first one

- [x] only rerender images that need it

- [x] render new image first before unrendering old one (smoother update)

- [x] figure out how to render multiline equations, matplotlib only works for one line currently

- [ ] be able to only render when hovering over latex

- [ ] be able to possibly hide the raw latex expression
* idea: make the text invisible and render the image above it. then when we hover over image - unrender it and make the raw latex visible again

- [ ] rerender on window size change? so that when zoomin in tmux it displays properly

### Stretch Goals

- [ ] be able to render in a popup or something while typing
* this would require a smarter and faster image generation/rendering pipeline
