!Mark Gomes
!CSC 330
!Assignment 2 - Diffusion Model
program diffusion

integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
real :: time
integer :: mem_stat
interface

subroutine create_cube(maxsize, cube)
integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
end subroutine create_cube

subroutine diffuse_cube(maxsize, cube, time)
integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
real :: time
end subroutine diffuse_cube

end interface

print *, "How big is the cube?"        ! Read in the cube dimension
read *, maxsize

call create_cube(maxsize, cube)
call diffuse_cube(maxsize, cube, time)
    write(*, 10) "Box equilibrated in ", time, " seconds of simulated time"
10 format(A, F12.8, A)

deallocate(cube, STAT=mem_stat)
if(mem_stat/=0) STOP "ERROR DEALLOCATING ARRAY"

end program diffusion

subroutine create_cube(maxsize, cube)
integer :: maxsize
real(kind=8), dimension(:,:,:), allocatable :: cube
integer :: mem_stat

allocate(cube(maxsize,maxsize,maxsize), STAT=mem_stat)      ! Instantiate the cube array
if(mem_stat/=0) STOP "MEMORY ALLOCATION ERROR"

forall(i = 1:maxsize, j = 1:maxsize, k = 1:maxsize) cube(i,j,k) = 0.0       ! Zero out the cube

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
                change = 0.0
                if(i - 1 > 0) then          ! Check that potential cube diffusion is in bounds
                    change = (cube(i,j,k) - cube(i-1,j,k)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i-1,j,k) = cube(i-1,j,k) + change
                end if

                if(i + 1 <= maxsize) then
                    change = (cube(i,j,k) - cube(i+1,j,k)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i+1,j,k) = cube(i+1,j,k) + change
                end if
                        
                if(j - 1 > 0) then
                    change = (cube(i,j,k) - cube(i,j-1,k)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i,j-1,k) = cube(i,j-1,k) + change
                end if

                if(j + 1 <= maxsize) then
                    change = (cube(i,j,k) - cube(i,j+1,k)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i,j+1,k) = cube(i,j+1,k) + change
                end if

                if(k - 1 > 0) then
                    change = (cube(i,j,k) - cube(i,j,k-1)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i,j,k-1) = cube(i,j,k-1) + change
                end if

                if(k + 1 <= maxsize) then
                    change = (cube(i,j,k) - cube(i,j,k+1)) * DTerm
                    cube(i,j,k) = cube(i,j,k) - change
                    cube(i,j,k+1) = cube(i,j,k+1) + change
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
                maxvalue = max(cube(i,j,k), maxvalue)
                minvalue = min(cube(i,j,k), minvalue)
                sumvalue = sumvalue + cube(i,j,k)
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
