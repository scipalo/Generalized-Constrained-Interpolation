# Generalized-Constrained-Interpolation

Generalized Constrained Interpolation is a project for masters degree. 
Its main topic is image magnification with interpolation methods. 

First goal is to implement algorithm described in "Generalized Constrained Interpolation" paper.

### Material in main repository:
* **Code** contains latest version of code in progress.
* Paper **Generalized Constrained Interpolation** is main paper with descriptions of algotithms.
* Paper **Constrain based interpolation** is base paper for "Generalized Constrained Interpolation"
* In **Progress description** results of written code and yet unsolved problems are described.

### Running the algorithm:

To run the algotithm we first need to install image package: ``` pkg install -forgenews image ```

Then run ```Init_script.m``` or ```pkg load image``` to load the image package in the workspace.

And we are ready to run scripts (sensor model, smoothing model, sharpening model).

### Algorithm has 3 main models: 
* **Sensor model** it keeps corrected image true to original, it keeps reversing pixel values.
* **Smoothing model** smooths the image.
* **Sharpening model** is composed of sharpening itself (**Nudge flow function**) and the stop criterium for sharpening (**Maximal slope**).

Mostly models are based on correcting pixel values based on dreivatives and curvature. More detailed description is in the papers.

