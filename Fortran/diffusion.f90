!Mark Gomes
!CSC 330
!Assignment 2 - Diffusion Model
program diffusion

integer :: maxsize
character :: userinput
logical :: partition
logical :: break
real(kind=8), dimension(:,:,:), allocatable :: cube
real :: time
integer :: mem_stat
interface

subroutine create_cube(maxsize, partition, cube)
integer :: maxsize
logical :: partition
real(kind=8), dimension(:,:,:), allocatable :: cube
end subroutine create_cube

subroutine diffuse_cube(maxsize, cube, time)
integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
real :: time
end subroutine diffuse_cube

end interface

print *, "Enter the room dimensions: "        ! Read in the cube dimension
read *, maxsize

break = .false.
print *, "Is there a partition? [y/n] : "       !Read in if there is a partition
do while(break .eqv. .false.)
    read *, userinput
    if (userinput == 'y') then
        partition = .true.
        break = .true.
    end if
    if (userinput == 'n') then
        break = .true.
    else
        print *, "Input was not accepted. Enter again. [y/n] : "
    end if
end do
maxsize = 10
partition = .true.

call create_cube(maxsize, partition, cube)
call diffuse_cube(maxsize, cube, time)
    write(*, 10) "Box equilibrated in ", time, " seconds of simulated time"
10 format(A, F12.8, A)

deallocate(cube, STAT=mem_stat)
if(mem_stat/=0) STOP "ERROR DEALLOCATING ARRAY"

end program diffusion

subroutine create_cube(maxsize, partition, cube)
integer :: maxsize
logical :: partition
real(kind=8), dimension(:,:,:), allocatable :: cube
integer :: mem_stat

allocate(cube(maxsize,maxsize,maxsize), STAT=mem_stat)      ! Instantiate the cube array
if(mem_stat/=0) STOP "MEMORY ALLOCATION ERROR"

forall(i = 1:maxsize, j = 1:maxsize, k = 1:maxsize) cube(i,j,k) = 0.0       ! Zero out the cube

if (partition .eqv. .true.) then
    do j=maxsize/2,maxsize            ! Adding in the partition
        do k=1,maxsize
            cube(maxsize/2+1,j,k) = -1.0
        end do
    end do
end if

end subroutine create_cube

subroutine diffuse_cube(maxsize, cube, time)
integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
real :: diffusion_coefficient = 0.175
real :: room_dimension = 5                   ! 5 meters
real :: speed_of_gas_molecules = 250.0       ! Based on 100 g/mol at RT
real :: timestep                             ! h in secs
real :: distance_between_blocks
real :: DTerm
real :: time
real :: ratio = 0.0
real :: change = 0.0
integer :: i
integer :: j
integer :: k
real :: sumvalue
real :: maxvalue
real :: minvalue

! Diffusion variable calculations
time = 0.0
timestep = (room_dimension / speed_of_gas_molecules) / maxsize
distance_between_blocks = room_dimension / maxsize
DTerm = diffusion_coefficient * timestep / (distance_between_blocks * distance_between_blocks)

! Intialize the first cell
cube(1,1,1) = 1.0e21

do while (ratio < 0.99)        ! Loop until maxval and minval are equal
    do i=1,maxsize              ! Iterate through every cube
        do j=1,maxsize
            do k=1,maxsize
                if(cube(i,j,k) /= -1.0) then
                    change = 0.0
                    if(i - 1 > 0 .and. cube(i-1,j,k) /= -1.0) then          ! Check that potential cube diffusion is in bounds
                        change = (cube(i,j,k) - cube(i-1,j,k)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i-1,j,k) = cube(i-1,j,k) + change
                    end if

                    if(i + 1 <= maxsize .and. cube(i+1,j,k) /= -1.0) then
                        change = (cube(i,j,k) - cube(i+1,j,k)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i+1,j,k) = cube(i+1,j,k) + change
                    end if
                        
                    if(j - 1 > 0 .and. cube(i,j-1,k) /= -1.0) then
                        change = (cube(i,j,k) - cube(i,j-1,k)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i,j-1,k) = cube(i,j-1,k) + change
                    end if

                    if(j + 1 <= maxsize .and. cube(i,j+1,k) /= -1.0) then
                        change = (cube(i,j,k) - cube(i,j+1,k)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i,j+1,k) = cube(i,j+1,k) + change
                    end if

                    if(k - 1 > 0 .and. cube(i,j,k-1) /= -1.0) then
                        change = (cube(i,j,k) - cube(i,j,k-1)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i,j,k-1) = cube(i,j,k-1) + change
                    end if

                    if(k + 1 <= maxsize .and. cube(i,j,k+1) /= -1.0) then
                        change = (cube(i,j,k) - cube(i,j,k+1)) * DTerm
                        cube(i,j,k) = cube(i,j,k) - change
                        cube(i,j,k+1) = cube(i,j,k+1) + change
                    end if
                end if
            end do
        end do
    end do
   
    ! Check for Mass Consistency
    maxvalue = cube(1,1,1)
    minvalue = cube(1,1,1)
    sumvalue = 0.0

    do i=1,maxsize
        do j=1,maxsize
            do k=1,maxsize
                if(cube(i,j,k) /=  -1.0) then
                    maxvalue = max(cube(i,j,k), maxvalue)
                    minvalue = min(cube(i,j,k), minvalue)
                    sumvalue = sumvalue + cube(i,j,k)
                end if
            end do
        end do
    end do
    
    time = time + timestep
    ratio = minvalue / maxvalue

    write(*, 20) "Time: ", time, "   Ratio:  ", ratio
20 format(A, F12.8, A, F12.8)
    write(*, 30) "Intial Cube: ", cube(1,1,1), "    Final Cube: ", cube(maxsize,maxsize,maxsize)
30 format(A, F35.2, A, F35.2)
    write(*, 40) "Sumval: ", sumvalue
40 format(A, F35.2)

end do

end subroutine diffuse_cube
