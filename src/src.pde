// vim:ft=java

PImage   imageSource;
PImage   imageThreshold;
PImage   imageEdge;
PImage   imageMask;
int      imageIndex = 0;
String[] imagePaths = {
  "paul-green-5lRxNLHfZOY-unsplash.resized.jpg",
  "chirag-saini-NiLu7snorsY-unsplash.resized.jpg",
  "brad-pearson-YnEhJ9dWT_M-unsplash.resized.jpg",
  "michelle-ding-28-vlghUMKo-unsplash.resized.jpg",
  "jd-x-qoLIbEPuY8U-unsplash.resized.jpg",
};

void setup() {
  size(200, 300, P3D);
  stroke(255);
  noFill();

  loadSource();
}

float value = 0.0;       // 0.0...1.0 // TODO Better name... animationStep or something
float modifier = 0.0;    // Sine wave mapped from -1...1 over time 0...1
float threshold = 0.0;   // Brightness threshold 0...255 # TODO: Why float?
float alpha = 0;         // Mask alpha
float multiplier = 1.5;  // Mask brightness multiplier

void draw() {
  value += map(mouseX, 0, width, 0.01, 0.1);
  value %= 1.0;

  modifier  = sin((value * TAU) - HALF_PI); // Desmos: \frac{\sin\left(x\tau-\frac{\pi}{2}\right)}{2}+0.5
  threshold = map( value, 0, 1, 0, 240 );
  //threshold = map( modifier, -1, 1, 100, 240 );
  //modifier  = sin((value * TAU) + HALF_PI);
  modifier  = (-1 * pow(value, 2) + value) * 4; // Desmos: \left(-1x^2+x\right)4
  alpha     = map( modifier, 0, 1, 0, 255 );

  generateThenDraw(threshold, 6f, int(alpha));

  saveFrame("frame-######.png");
}

void mousePressed() {
  if (mouseButton == LEFT) {
    imageIndex--;
    if (imageIndex < 0) imageIndex = imagePaths.length - 1;
    loadSource();
  } else if (mouseButton == RIGHT) {
    imageIndex++;
    if (imageIndex >= imagePaths.length) imageIndex = 0;
    loadSource();
  }
}

void loadSource() {
  imageSource    = loadImage(imagePaths[imageIndex]);
  imageThreshold = createImage(imageSource.width, imageSource.height, ARGB);
  imageEdge      = createImage(imageSource.width, imageSource.height, ARGB);
  imageMask      = createImage(imageSource.width, imageSource.height, ARGB);
}

void generateThenDraw(float threshold, float kernel, int alpha) {
  generateImageThreshold(imageSource, threshold, imageThreshold);
  generateImageEdge(imageThreshold, kernel, imageEdge);
  generateImageMask(imageSource, imageEdge, alpha, imageMask);

  background(0);
  image(imageSource, 0, 0);
  image(imageMask, 0, 0);

  //println("threshold: ", threshold, " - ", "kernel: ", kernel, " - ", "alpha: ", alpha);
  //println("threshold: ", int(threshold), " - ", "alpha: ", alpha);
}

void generateImageThreshold(PImage image, float threshold, PImage target) {
  image.loadPixels();

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int   pixelPosition   = y * image.width + x;
      float pixelBrightness = brightness(image.pixels[pixelPosition]);
      color targetColor     = color(pixelBrightness > threshold ? 255 : 0);

      target.pixels[pixelPosition] = targetColor;
    }
  }

  target.updatePixels();
}

void generateImageEdge(PImage image, float width, PImage target) {
  float[][] kernel = {{ -1,    -1, -1 },
                      { -1, width, -1 },
                      { -1,    -1, -1 }};

  image.loadPixels();

  for (int y = 1; y < image.height - 1; y++) {                      // Skip top and bottom edges
    for (int x = 1; x < image.width - 1; x++) {                     // Skip left and right edges
      float sum = 0;                                                // Kernel sum for this pixel

      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int pos = (y + ky) * image.width + (x + kx);              // Calculate the adjacent pixel for this kernel point
          float val = red(image.pixels[pos]);                       // Image is grayscale, red/green/blue are identical
          sum += kernel[ky+1][kx+1] * val;                          // Multiply adjacent pixels based on the kernel values
        }
      }

      int   pixelPosition = y * image.width + x;
      color targetColor   = color(sum, sum, sum); // For this pixel in the new image, set the gray value based on the sum from the kernel

      target.pixels[pixelPosition] = targetColor;
    }
  }

  target.updatePixels();
}

void generateImageMask(PImage source, PImage mask, int alpha, PImage target) {
  source.loadPixels();
  mask.loadPixels();

  for (int y = 0; y < source.height; y++) {
    for (int x = 0; x < source.width; x++) {
      int   pixelPosition = y * source.width + x;
      color sourceColor   = source.pixels[pixelPosition];
      color maskColor     = mask.pixels[pixelPosition];
      color targetColor   = 0;
      //color targetColor   = (maskColor & 0x00FFFFFF) != 0 ? sourceColor : 0; // If there's any color value, use the source color, otherwise use blank pixel

      //targetColor = (targetColor & 0x00FFFFFF) | (alpha << 24);

      if ((maskColor & 0x00FFFFFF) != 0) {                      // If there's any color value
        targetColor = (sourceColor & 0x00FFFFFF);               // Set target pixel color to source's pixel color at position (without alpha channel)

        // Split channels and increase each channel slightly
        int targetColorR = int( constrain(red(targetColor)   * multiplier, 0, 255) );
        int targetColorG = int( constrain(green(targetColor) * multiplier, 0, 255) );
        int targetColorB = int( constrain(blue(targetColor)  * multiplier, 0, 255) );

        targetColor = color(targetColorR, targetColorG, targetColorB, alpha); // Combine channels
      }

      target.pixels[pixelPosition] = targetColor;
    }
  }

  target.updatePixels();
}

