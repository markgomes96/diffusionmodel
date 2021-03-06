/* Mark Gomes
 * CSC 330 
 * Dr. Pounds
 * Assignment 2 : Diffusion Model
 */
using System;
using System.Diagnostics;

public class diffusion
{
    static public void Main()
    {
        
        int maxsize = 0;              //Dimension of the cube
        Console.Write("Enter the room dimensions: ");
        while(maxsize < 1)            //Reads user input for room dimensions  
        {
            try
            {
                maxsize = Convert.ToInt32(Console.ReadLine());
            }
            catch
            {  
                Console.Write("Input was not accepted. Enter again: ");
            }
        }
        
        bool partition = false;
        string userinput;
        Console.Write("Is there a partition? [y/n] : ");
        while(true)                 //Reads user input to determine if there is a partition
        {
            userinput = Console.ReadLine();
            if(userinput == "y")
            {
                partition = true;
                break;
            }
            if(userinput == "n")
            {   
                break;
            }
            Console.Write("Input was not accepted. Enter again. [y/n] : ");
        }

        double[,,] cube = new double[maxsize,maxsize,maxsize];      //Instantiate the 3d cube array

        //Zero the cube
        for (int i = 0; i < maxsize; i++)
        {
            for (int j = 0; j < maxsize; j++)
            {
                for (int k = maxsize/2; k < maxsize; k++)
                {
                    cube[i,j,k] = 0.0;
                }
            }
        }

        //Adding in the partition
        if(partition == true)
        {
            for (int j = maxsize/2-1; j < maxsize; j++)
            {
                for (int k = 0; k < maxsize; k++)
                {
                    cube[maxsize/2,j,k] = -1.0;
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
        cube[0,0,0] = 1.0e21;

        double time = 0.0;          // To keep up with accumulated system time
        double ratio = 0.0;

        Stopwatch sw = new Stopwatch();
        sw.Start();
        do                      // Loop until the minvalue and maxvalue is the same
        {
            for (int i = 0; i < maxsize; i++)           // Iterate though each cube in the array
            {
                for (int j = 0; j < maxsize; j++)
                {
                    for (int k = 0; k < maxsize; k++)
                    {
                        if(cube[i,j,k] != -1.0)             // Checks if the cube is a partition
                        {
                            double change = 0.0;
                            if(i - 1 >= 0 && cube[i-1,j,k] != -1.0)         // Checks that potential cube diffusion is not out of bounds
                            {
                                change = (cube[i,j,k] - cube[i-1,j,k]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i-1,j,k] = cube[i-1,j,k] + change;
                            }

                            if(i + 1 < maxsize && cube[i+1,j,k] != -1.0)
                            {
                                change = (cube[i,j,k] - cube[i+1,j,k]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i+1,j,k] = cube[i+1,j,k] + change;
                            }
                        
                            if(j - 1 >= 0 && cube[i,j-1,k] != -1.0)
                            {
                                change = (cube[i,j,k] - cube[i,j-1,k]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i,j-1,k] = cube[i,j-1,k] + change;
                            }

                            if(j + 1 < maxsize && cube[i,j+1,k] != -1.0)
                            {
                                change = (cube[i,j,k] - cube[i,j+1,k]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i,j+1,k] = cube[i,j+1,k] + change;
                            }

                            if(k - 1 >= 0 && cube[i,j,k-1] != -1.0)
                            {
                                change = (cube[i,j,k] - cube[i,j,k-1]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i,j,k-1] = cube[i,j,k-1] + change;
                            }

                            if(k + 1 < maxsize && cube[i,j,k+1] != -1.0)
                            {
                                change = (cube[i,j,k] - cube[i,j,k+1]) * DTerm;
                                cube[i,j,k] = cube[i,j,k] - change;
                                cube[i,j,k+1] = cube[i,j,k+1] + change;
                            }
                        }
                    }
                }
            }

            time = time + timestep;

            // Check for Mass Consistency //
            double sumval = 0.0;
            double maxval = cube[0,0,0];
            double minval = cube[0,0,0];
            for (int i = 0; i < maxsize; i++)
            {
                for (int j = 0; j < maxsize; j++)
                {
                    for (int k = 0; k < maxsize; k++)
                    {
                        if(cube[i,j,k] != -1.0)         // Checks if the cube is a partition
                        {
                            maxval = Math.Max(cube[i,j,k], maxval);
                            minval = Math.Min(cube[i,j,k], minval);
                            sumval += cube[i,j,k];
                        }
                    }
                }
            }

            ratio = minval / maxval;

            Console.WriteLine("Time: " + time + "   Ratio: " + ratio);              // Displays diffusion stats
            Console.WriteLine("Intial Cube:  " + cube[0,0,0] + "   Final Cube: " + cube[maxsize - 1,maxsize - 1,maxsize - 1]);
            Console.WriteLine("Sumval: " + sumval);

        } while (ratio < 0.99);
        
        sw.Stop();
        Console.WriteLine("****************************************************************");
        Console.WriteLine("Box equilibrated in " + sw.Elapsed + " seconds of wall-time");
        Console.WriteLine("Box equilibrated in " + time + " seconds of simulated-time");
    }
}
