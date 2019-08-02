# Threshold Edge Detection Composite

> Click image to view in a much higher-quality Gyfcat/WebM video

<a href="https://gfycat.com/pointlessunhealthyhorsefly">![](example.gif)</a>

## How

* For each frame
  * Create "threshold image" using simple threshold algorithm
  * Detect edges on the threshold image
  * Mask source image with the edge-detected threshold image
  * Brighten mask image
  * Create composite of source image with mask image
  * Increase threshold value

This creates a neat line-scanning type animation. Kind of like the terminator scanning a subject.  
Works best on large, high quality images with a large depth of field.

## Usage

* Clone project
* Add images to the `data/` directory
* Edit `imagePaths` list within `src/src.pde` to include your images
* Run `make run`
* Left/right click to change images

To render out to individual frames, uncomment the `saveFrame` line within the `draw` function.

## Contributing

1. Fork it (<https://github.com/RyanScottLewis/path_tree_viewer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This program is available as open source under the terms of the MIT License <http://opensource.org/licenses/MIT>.
