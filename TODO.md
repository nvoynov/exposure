% TODO

# Docs design (analyst)

- [ ] tidy up user requirements for gallery synchronization
- [ ] design detailed requirements for gallery import
- [ ] photo size optimization for differen screens (PC, tablets, phones)

# Code design (developer)

- [ ] integrate expostion image creation into import pipeline
  - [ ] try tpo extract and isolate the image magick command
- [ ] integrate series image image creation into import pipeline   
- [ ] refactor dependecy injection of adapters into intractors (tasks)

- [x] design merging albums tests
- [x] fix albums merging
  - [x] insert new pictures into storyboard according to original craation time
  - [x] do not repeat html comment about describing
  - [x] move the commend abouve from code into Config

# Site design (web developer)

- [ ] create the exposition presentation image for social media by sharing the exposition link
  - [ ] it must mimic "Todd Hido" image wall
  - [ ] it must add the gallery watermark (focusing-screen.svg)
  - [ ] find proper place for the foucing-scrieen logo
- [ ] create series/album presentation image for social media by sharing the series link
  - [ ] it must mimic series block on /series page
  - [ ] the same stuff with focusing-screen logo
- [ ] fix "the exposition lost favicon" problem

- [x] simplify lightbox by removing image framing (mat and frame)
  - [x] only image and white box around left, no title
  - [x] only one dark gray background
  - [x] "full screen", 'link', "close" options
- [x] new favicon.svg
- [x] new foucusing-screen.svg icon а f
- [x] use focusing-screen.svg in site header as a divider instead of dot between `Nikolay Voynov. Exposure`
- [ ] update about page by removing frame and adding avatar (see docs/assets/about_view.svg)

# Gallery owner

- [ ] clean up source albbums according new print order
  - [ ] Almazone
  - [ ] Svalovichi
  - [ ] Bubbles (think about new name for the album)
  - [ ] Vaseline (think about new name for the album)
- [ ] finaly describe albums for SEO (right order, cover, keywords) and individual images
  - [ ] Almazone
  - [ ] Svalovichi
  - [ ] Bubbles (think about new name for the album)
  - [ ] Vaseline (think about new name for the album)
- [ ] prepare two new albums
  - [ ] Stonetomb
  - [ ] Kytaevo



