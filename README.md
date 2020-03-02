# NapoleonNotebook
Yan Bo's Coding Samples

In "estimate impulse responses by local projections," I explore the response of major macroeconomic variables
to changes in total factor productivity (Ramey 2016). This short work includes constructing a time series dataset,
using a local projection approach to estimate the impulse responses (Jordà 2005) of these variables to two
different series of shocks to total factor productivity, and visualizing the results estimated at various horizons.

It is originally an RA task submitted to Professor Emil Verner of MIT Sloan. I also reused it for my current research
project at Volatility and Risk Institute of NYU Stern.

For this task, I had to thoroughly understand the novel econometric idea and begin implementing it as soon as I finish studying
the papers and conference lectures. Before writing the code, I replicated the mathematical derivation and logical
flow introduced in the papers by hand. I started simple but with a high degree of rigorousness. The code was then written
in such a way that it should be reusable for a different application. I also emphasized the use of flexible programming
and subroutines and minimized copying and pasting. It took me hours to debug for the plotting function and figure out
how lag, lead, and NeweyWest functions work with different time series objects in R. I am happy for the experience and technical
skills I learned from it.

"Python Coding Sample" is a final project report for an undergraduate data science course. It shows my familiarity in Python for
data analysis and statistical learning. I would like to thank Annie Lee and Mellissa Perez for their contributions in the
background research and final presentation.

"tic_tac_toe": Type play() on the console to start a tic tac toe game. Please first execute the entire script.
