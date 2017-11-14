/* Mark Gomes
 * CSC 330
 * Dr. Pounds
 * Assignment 2 - Diffusion Model
 */
package main

import "fmt"
import "math"

func main(){
    //Change maxsize const to change room dimension
    const maxsize int = 10      //***Dimension of the cube***
    var cube [maxsize][maxsize][maxsize] float64       // Instantiate the cube array
    
    var userinput string
    var partition bool = false
    fmt.Printf("Is there a partition? [y/n] : ")
    for {
        fmt.Scanf("%s", &userinput)
        if userinput == "y" {
            partition = true
            break
        }
        if userinput == "n" {
            break
        }
        fmt.Printf("Input was not accepted. Enter again. [y/n] : ")
    }
    
    var i, j, k int
        
    // Zero the cube
    for i = 0; i < maxsize; i++ {
        for j = 0; j < maxsize; j++ {
            for k = 0; k < maxsize; k++ {
                cube[i][j][k] = 0.0
            }
        }
    }
    
    // Add in partition
    if partition == true {
        for j = maxsize/2-1; j < maxsize; j++ {
            for k = 0; k < maxsize; k++ {
                cube[maxsize/2][j][k] = -1.0
            }
        }
    }

    // Diffusion Variables
    var diffusion_coefficient float64 = 0.175
    var room_dimension float64 = 5.0                    // 5 meters
    var speed_of_gas_molecules float64 = 250.0        // Based on 100 g/mol gas at RT
    var timestep float64 = (room_dimension / speed_of_gas_molecules) / float64(maxsize)      // h in seconds
    var distance_between_blocks float64 = room_dimension / float64(maxsize)
    var change float64
    var DTerm float64 = diffusion_coefficient * timestep /
                (distance_between_blocks * distance_between_blocks)
    var sumval float64
    var maxval float64
    var minval float64
    
    //Intialize the first cell
    cube[0][0][0] = 1.0e21

    var time float64 = 0.0          // To keep up with accumulated system time
    var ratio float64 = 0.0

    for {          // Loop until the maxval and minval are the same
        for i = 0; i < maxsize; i++ {        // Iterate through every cube in the array
            for j = 0; j < maxsize; j++ {
                for k = 0; k < maxsize; k++ {
                    if cube[i][j][k] != -1.0 {      // Check if cube is a partition
                        change = 0.0
                        if i - 1 >= 0 && cube[i-1][j][k] != -1.0 {      // Check if the potential cube diffusion is within bounds
                            change = (cube[i][j][k] - cube[i-1][j][k]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i-1][j][k] = cube[i-1][j][k] + change
                        }
    
                        if i + 1 < maxsize && cube[i+1][j][k] != -1.0 {
                            change = (cube[i][j][k] - cube[i+1][j][k]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i+1][j][k] = cube[i+1][j][k] + change
                        }
                            
                        if j - 1 >= 0 && cube[i][j-1][k] != -1.0 {
                            change = (cube[i][j][k] - cube[i][j-1][k]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i][j-1][k] = cube[i][j-1][k] + change
                        }
    
                        if j + 1 < maxsize && cube[i][j+1][k] != -1.0 {
                            change = (cube[i][j][k] - cube[i][j+1][k]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i][j+1][k] = cube[i][j+1][k] + change
                        }
    
                        if k - 1 >= 0 && cube[i][j][k-1] != -1.0 {
                            change = (cube[i][j][k] - cube[i][j][k-1]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i][j][k-1] = cube[i][j][k-1] + change
                        }
    
                        if k + 1 < maxsize && cube[i][j][k+1] != -1.0 {
                            change = (cube[i][j][k] - cube[i][j][k+1]) * DTerm
                            cube[i][j][k] = cube[i][j][k] - change
                            cube[i][j][k+1] = cube[i][j][k+1] + change
                        }
                    }
                }
            }
        }

        time = time + timestep

        // Check for Mass Consistency //
        sumval = 0.0
        maxval = cube[0][0][0]
        minval = cube[0][0][0]
        for i = 0; i < maxsize; i++ {
            for j = 0; j < maxsize; j++ {
                for k = 0; k < maxsize; k++ {
                    if cube[i][j][k] != -1.0 {
                        maxval = math.Max(cube[i][j][k], maxval)
                        minval = math.Min(cube[i][j][k], minval)
                        sumval += cube[i][j][k]
                    }
                }
            }
        }

        ratio = minval / maxval

        // Display diffusion stats
        fmt.Printf("Time: %f   Ratio: %f \n", time, ratio)
        fmt.Printf("Intial Cube: %f   Final Cube: %f \n", cube[0][0][0], cube[maxsize-1][maxsize-1][maxsize-1])
        fmt.Printf("Sumvalue: %f \n", sumval)

        if  ratio >= 0.99 { break }
    }

    fmt.Printf("Box equilibrated in %f seconds of simulated time. \n", time)
}
