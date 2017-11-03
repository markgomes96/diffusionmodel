/* Mark Gomes
 * CSC 330
 * Dr. Pounds
 * Assingment 2 : Diffusion Model
 */
#include <stdio.h>
#include <stdlib.h>

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

int main(int argc, char** argv)
{
    const int maxsize = 10;         // Dimension of the cube
    int i, j, k;

    //Declare the multidimensional array
    double ***cube = malloc(maxsize*sizeof(double**));
    for(i = 0; i < maxsize; i++)
    {
        cube[i] = malloc(maxsize*sizeof(double*));
        for(j = 0; j < maxsize; j++)
        {
            cube[i][j] = malloc(maxsize*sizeof(double));
        }
    }
        
    //Zero the cube
    for (int i = 0; i < maxsize; i++)
    {
        for (int j = 0; j < maxsize; j++)
        {
            for (int k = 0; k < maxsize; k++)
            {
                cube[i][j][k] = 0.0;
            }
        }
    }

    //Diffusion variables
    double diffusion_coefficient = 0.175;
    double room_dimension = 5;                  // 5 meters
    double speed_of_gas_molecules = 250.0;      // Based on 100 g/mol gas at RT
    double timestep = (room_dimension / speed_of_gas_molecules) / maxsize;  // h in seconds
    double distance_between_blocks = room_dimension / maxsize;

    double DTerm = diffusion_coefficient * timestep /
                (distance_between_blocks * distance_between_blocks);

    //Intialize the first cell
    cube[0][0][0] = 1.0e21;

    int pass = 0;
    double time = 0.0;          // To keep up with accumulated system time
    double ratio = 0.0;

    do                  //Loop until the minval and maxval are the same
    {
        for (int i = 0; i < maxsize; i++)       //Iterate though each cube in the array
        {
            for (int j = 0; j < maxsize; j++)
            {
                for (int k = 0; k < maxsize; k++)
                {
                    double change = 0.0;
                    if(i - 1 >= 0)      //Checks that potential cube diffusion is not out of bounds
                    {
                        change = (cube[i][j][k] - cube[i-1][j][k]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i-1][j][k] = cube[i-1][j][k] + change;
                    }

                    if(i + 1 < maxsize)
                    {
                        change = (cube[i][j][k] - cube[i+1][j][k]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i+1][j][k] = cube[i+1][j][k] + change;
                    }
                        
                    if(j - 1 >= 0)
                    {
                        change = (cube[i][j][k] - cube[i][j-1][k]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i][j-1][k] = cube[i][j-1][k] + change;
                    }

                    if(j + 1 < maxsize)
                    {
                        change = (cube[i][j][k] - cube[i][j+1][k]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i][j+1][k] = cube[i][j+1][k] + change;
                    }

                    if(k - 1 >= 0)
                    {
                        change = (cube[i][j][k] - cube[i][j][k-1]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i][j][k-1] = cube[i][j][k-1] + change;
                    }

                    if(k + 1 < maxsize)
                    {
                        change = (cube[i][j][k] - cube[i][j][k+1]) * DTerm;
                        cube[i][j][k] = cube[i][j][k] - change;
                        cube[i][j][k+1] = cube[i][j][k+1] + change;
                    }
                }
            }
        }

        time = time + timestep;

        // Check for Mass Consistency //
        double sumval = 0.0;
        double maxval = cube[0][0][0];
        double minval = cube[0][0][0];
        for (int i = 0; i < maxsize; i++)
        {
            for (int j = 0; j < maxsize; j++)
            {
                for (int k = 0; k < maxsize; k++)
                {
                    maxval = max(cube[i][j][k], maxval);
                    minval = min(cube[i][j][k], minval);
                    sumval += cube[i][j][k];
                }
            }
        }

        ratio = minval / maxval;

        printf("Time: %lf   Ratio: %lf \n", time, ratio);
        printf("Intial Cube: %lf   Final Cube: %lf \n", cube[0,0,0], cube[maxsize-1,maxsize-1,maxsize-1]);
        printf("Sumval: %lf \n", sumval);

    } while (ratio < 0.99);

    printf("Box equilibrated in %lf seconds of simulated time. \n", time);
}
