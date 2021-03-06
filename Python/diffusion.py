#!/usr/bin/python
#Mark Gomes
#CSC 330
#Dr. Pounds
#Assignment 2 - Diffusion Model

import sys

# Read user input for the room dimension
maxsize = 0
while maxsize < 1:
    try:
        maxsize = int(input("Enter the room dimension: "))
    except:
        print "Input was not accepted. Enter again: "

# Read user input to determine if there is a partition
partition = False
print "Is there a partition? [y/n] : "
while True:
    userinput = sys.stdin.read(1)
    if userinput == 'y':
        partition = True
        break
    if userinput == 'n':
        break
    if userinput != '\n':
        sys.stdin.read(1)
    print "Input was not accepted. Enter again. [y/n] : "

# Create cube
cube = [[[0.0 for k in range(maxsize)] for j in range(maxsize)] for i in range(maxsize)]

# Zero cube
for i in range(0,maxsize):
    for j in range(0,maxsize):
        for k in range(0,maxsize):
            cube[i][j][k] = 0.0

# Add in partition
if(partition == True):
    for j in range(maxsize/2-1,maxsize):
        for k in range(0,maxsize):
            cube[maxsize/2][j][k] = -1.0

# Diffusion Variables
diffusion_coefficient = 0.175
room_dimension = 5                   # 5 meters
speed_of_gas_molecules = 250.0       # Based on 100 g/mol at RT
ratio = 0.0
change = 0.0
time = 0.0
timestep = (room_dimension / speed_of_gas_molecules) / maxsize
distance_between_blocks = float(room_dimension) / float(maxsize)
DTerm = diffusion_coefficient * timestep / (distance_between_blocks * distance_between_blocks)

#Intialize the first cell
cube[0][0][0] = 1.0e21

while True:             # Loop until maxval and minval are the same
    for i in range(0,maxsize):        # Iterate through the every cube
        for j in range(0,maxsize):
            for k in range(0,maxsize):
                if cube[i][j][k] != -1.0:       #Checks if cube is a partition
                    change = 0.0
                    if i - 1 >= 0 and cube[i-1][j][k] != -1.0:      #Checks if potential cube diffusion is within bounds
                        change = (cube[i][j][k] - cube[i-1][j][k]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i-1][j][k] = cube[i-1][j][k] + change

                    if i + 1 < maxsize and cube[i+1][j][k] != -1.0:
                        change = (cube[i][j][k] - cube[i+1][j][k]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i+1][j][k] = cube[i+1][j][k] + change
                        
                    if j - 1 >= 0 and cube[i][j-1][k] != -1.0:
                        change = (cube[i][j][k] - cube[i][j-1][k]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i][j-1][k] = cube[i][j-1][k] + change

                    if j + 1 < maxsize and cube[i][j+1][k] != -1.0:
                        change = (cube[i][j][k] - cube[i][j+1][k]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i][j+1][k] = cube[i][j+1][k] + change

                    if k - 1 >= 0 and cube[i][j][k-1] != -1.0:
                        change = (cube[i][j][k] - cube[i][j][k-1]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i][j][k-1] = cube[i][j][k-1] + change

                    if k + 1 < maxsize and cube[i][j][k+1] != -1.0:
                        change = (cube[i][j][k] - cube[i][j][k+1]) * DTerm
                        cube[i][j][k] = cube[i][j][k] - change
                        cube[i][j][k+1] = cube[i][j][k+1] + change
                
    #Check for Mass Consistency
    maxvalue = cube[0][0][0]
    minvalue = cube[0][0][0]
    sumvalue = 0.0

    for i in range(0,maxsize):
        for j in range(0,maxsize):
            for k in range(0,maxsize):
                if cube[i][j][k] != -1.0:
                    maxvalue = max(cube[i][j][k], maxvalue)
                    minvalue = min(cube[i][j][k], minvalue)
                    sumvalue = sumvalue + cube[i][j][k]
    
    time = time + timestep
    ratio = minvalue / maxvalue
    print "Time: ",time,"   Ratio: ",ratio
    print "Intial Cube: ",cube[0][0][0],"   Final Cube: ",cube[maxsize-1][maxsize-1][maxsize-1]
    print "Sumvalue: ", sumvalue
    if ratio >= 0.99:
        break

print "Box equilibrated in ", time, " seconds of simulated time"
