#!/usr/bin/sbcl --script
#||
Mark Gomes
CSC 330
Assignment 2 - Diffusion Model
||#

(defvar maxsize 10)

;;;Declare the multidimensional array
;;; Define a name to be used as a variable
(defvar A)

;;; Set up the variable to hold 3-D array
(setf A (make-array '(10 10 10)))

;;; Zero the cube
(dotimes(i maxsize)
  (dotimes(j maxsize)
    (dotimes(k maxsize)
       (setf(aref A i j k) 0.0)
    )
  )
)

;;; Add in partition
(dotimes(j (+ (/ maxsize 2) 1))
  (dotimes(k maxsize)
    (setf(aref A (/ maxsize 2) (+ j (- (/ maxsize 2) 1)) k) -1.0)
  )
)

(dotimes(i maxsize)
  (dotimes(j maxsize)
    (dotimes(k maxsize)
      (format t "~D ~D ~D: ~F~%" i j k (aref A i j k))
    )
  )
)

;;; Diffusion variables
(defvar diffusion_coefficient 0.175)
(defvar room_dimension  5.0)                  ;; 5 meters
(defvar speed_of_gas_molecules  250.0)      ;; Based on 100 g/mol gas at RT
(defvar timestep (/ (/ room_dimension speed_of_gas_molecules) maxsize))     ;; h in seconds
(defvar distance_between_blocks (/ room_dimension maxsize))
(defvar change)
(defvar DTerm (/ (* diffusion_coefficient timestep) (* distance_between_blocks distance_between_blocks)))

;;;Intialize the first cell
(setf(aref A 0 0 0) 1.0e21)
    
(defvar sumval)
(defvar maxval)
(defvar minval)
(defvar timevar 0.0)          ;; To keep up with accumulated system time
(defvar ratiovar 0.0)

(loop               ;;; Loop until maxval and minval are the same
  (dotimes(i maxsize)       ;;; Iterate through every cube in array
    (dotimes(j maxsize)
      (dotimes(k maxsize)
        (if (/= (aref A i j k) -1.0)
          (progn
          (if (and (>= (- i 1) 0) (/= (aref A (- i 1) j k) -1.0))          ;;; Check if potential diffusion is within bounds
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A (- i 1) j k))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A (- i 1) j k) (+ (aref A (- i 1) j k) change))
            )
          )
          
          (if (and (< (+ i 1) maxsize) (/= (aref A (+ i 1) j k) -1.0))
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A (+ i 1) j k))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A (+ i 1) j k) (+ (aref A (+ i 1) j k) change))
            )
          )
          
          (if (and (>= (- j 1) 0) (/= (aref A i (- j 1) k) -1.0))
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A i (- j 1) k))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A i (- j 1) k) (+ (aref A i (- j 1) k) change))
            )
          )
          
          (if (and (< (+ j 1) maxsize) (/= (aref A i (+ j 1) k) -1.0))
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A i (+ j 1) k))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A i (+ j 1) k) (+ (aref A i (+ j 1) k) change))
            )
          )
          
          (if (and (>= (- k 1) 0) (/= (aref A i j (- k 1)) -1.0))
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A i j (- k 1)))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A i j (- k 1)) (+ (aref A i j (- k 1)) change))
            )
          )
          
          (if (and (< (+ k 1) maxsize) (/= (aref A i j (+ k 1)) -1.0))
            (progn
            (setf change (* DTerm (- (aref A i j k) (aref A i j (+ k 1)))))
            (setf (aref A i j k) (- (aref A i j k) change))
            (setf (aref A i j (+ k 1)) (+ (aref A i j (+ k 1)) change))
            )
          )
          )
        )
      )
    )
  )

  (setf timevar (+ timevar timestep))

  ;;; Check for Mass Consistency
  (setf sumval 0.0)
  (setf maxval (aref A 0 0 0))
  (setf minval (aref A 0 0 0))
  
  (dotimes(i maxsize)
    (dotimes(j maxsize)
      (dotimes(k maxsize)
        (if (/= (aref A i j k) -1.0)
          (progn
          (setf maxval (max (aref A i j k) maxval)) 
          (setf minval (min (aref A i j k) minval))
          (setf sumval (+ sumval (aref A i j k)))
          )
        )
      )
    )
  )
  
  (setf ratiovar (/ minval maxval))

  ;;; Display Diffusion Stats
  (format t "Time: ~F~%    Ratio: ~F~%" timevar ratiovar)
  (format t "Intial Cube: ~F~%    Final Cube: ~F~%" (aref A 0 0 0) (aref A (- maxsize 1) (- maxsize 1) (- maxsize 1)))
  (format t "Sumval: ~F~%" sumval)

  (when (>= ratiovar 0.99) (return ratiovar))
)

(format t "Box equilibrated in ~F~%" timevar)
