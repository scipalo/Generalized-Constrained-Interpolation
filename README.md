# Generalized-Constrained-Interpolation

Generalized Constrained Interpolation is a project for masters degree. 
Its main topic is image magnification with interpolation methods. 

First goal is to implement algorithm described in "Generalized Constrained Interpolation" paper.

Material in main repository:
* **Code in progress** contains latest version of code in progress.
* **Scripts for examination** contains executable scripts meant for analising specific problems.
* Paper **Generalized Constrained Interpolatio** is the main paper with description of the algotithm for implemetnation.
* Paper **Constrain based interpolation** is the base paper for "Generalized Constrained Interpolation"
* In **Progress description** I presented results of written code and yet unsolved problems.

Algorithm:

To run algotithm we need first to instal image package: _pkg install -forgenews image_
**Init_script.m** loads the image package in the workspace and we are ready to run the program.

Algorithm has 3 main models: 
* **Sensor model** it keeps corrected image true to original, it keeps reversing pixel values.
* **Smoothing model** smooths the image.
* **Sharpening model** is composed of sharpening itself (**Nudge flow function**) and the stop criterium for sharpening (**Maximal slope**).

Mostly algotihm is based on corecting pixel values based on dreivatives and curvature. More detailed description is in the papers.

