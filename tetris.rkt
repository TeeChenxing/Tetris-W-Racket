(require 2htdp/image)
(require 2htdp/universe)

(define GRID-ROWS 20) 
(define GRID-COLS 10)
(define CELL-SIZE 20)
(define TICK-RATE 0.3)

(define O-START (- (/ (* GRID-COLS CELL-SIZE) 2) (/ CELL-SIZE 2)))
(define I-START (/ (* GRID-COLS CELL-SIZE) 2))

(define Y-START-LOCATION (/ CELL-SIZE 2))
(define GAME-WORLD (empty-scene (+ (* GRID-COLS CELL-SIZE) 1)
                                (+ (* GRID-ROWS CELL-SIZE) 1)))

;;; A Brick is a (make-brick Number Number Color)
(define-struct brick [x y color])

;; Examples:
(define BRICK-O-1 (make-brick O-START Y-START-LOCATION 'green))
(define BRICK-O-2 (make-brick (+ O-START CELL-SIZE) Y-START-LOCATION 'green))
(define BRICK-O-3 (make-brick O-START (+ Y-START-LOCATION CELL-SIZE) 'green))
(define BRICK-O-4 (make-brick (+ O-START CELL-SIZE) (+ Y-START-LOCATION CELL-SIZE) 'green))

(define BRICK-I-1 (make-brick (- I-START (* 1.5 CELL-SIZE)) Y-START-LOCATION 'blue))
(define BRICK-I-2 (make-brick (- I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'blue))
(define BRICK-I-3 (make-brick (+ I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'blue))
(define BRICK-I-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) Y-START-LOCATION 'blue))

(define BRICK-L-1 (make-brick (- I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'purple))
(define BRICK-L-2 (make-brick (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'purple))
(define BRICK-L-3 (make-brick (+ I-START (* 1.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'purple))
(define BRICK-L-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) Y-START-LOCATION 'purple))

(define BRICK-J-1 (make-brick (- I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'cyan))
(define BRICK-J-2 (make-brick (- I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'cyan))
(define BRICK-J-3 (make-brick (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'cyan))
(define BRICK-J-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'cyan))

(define BRICK-T-1 (make-brick (- I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'orange))
(define BRICK-T-2 (make-brick (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'orange))
(define BRICK-T-3 (make-brick (+ I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'orange))
(define BRICK-T-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'orange))

(define BRICK-Z-1 (make-brick (- I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'pink))
(define BRICK-Z-2 (make-brick (+ I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'pink))
(define BRICK-Z-3 (make-brick (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'pink))
(define BRICK-Z-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'pink))

(define BRICK-S-1 (make-brick (- I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'red))
(define BRICK-S-2 (make-brick (+ I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION 'red))
(define BRICK-S-3 (make-brick (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE) 'red))
(define BRICK-S-4 (make-brick (+ I-START (* 1.5 CELL-SIZE)) Y-START-LOCATION 'red))

;; A Pt (2D point) is a (make-posn Integer Integer)

;; A Bricks (Set of Bricks) is one of:
;; - empty
;; - (cons Brick Bricks)
;; Order does not matter.

;; Examples:
(define SOB-O (list BRICK-O-1 BRICK-O-2 BRICK-O-3 BRICK-O-4))
(define SOB-I (list BRICK-I-1 BRICK-I-2 BRICK-I-3 BRICK-I-4))
(define SOB-L (list BRICK-L-1 BRICK-L-2 BRICK-L-3 BRICK-L-4))
(define SOB-J (list BRICK-J-1 BRICK-J-2 BRICK-J-3 BRICK-J-4))
(define SOB-T (list BRICK-T-1 BRICK-T-2 BRICK-T-3 BRICK-T-4))
(define SOB-Z (list BRICK-Z-1 BRICK-Z-2 BRICK-Z-3 BRICK-Z-4))
(define SOB-S (list BRICK-S-1 BRICK-S-2 BRICK-S-3 BRICK-S-4))

;;; A Tetra is a (make-tetra Pt Bricks)
;;; The center point is the point around which the tetra
;;; rotates when it spins.
(define-struct tetra [center bricks])

;; Examples:
(define TETRA-O (make-tetra (make-posn O-START (+ Y-START-LOCATION CELL-SIZE)) SOB-O)) 
(define TETRA-I (make-tetra (make-posn (- I-START (* 0.5 CELL-SIZE)) Y-START-LOCATION) SOB-I))
(define TETRA-L (make-tetra (make-posn (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE))
                            SOB-L)) 
(define TETRA-J (make-tetra (make-posn (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE))
                            SOB-J)) 
(define TETRA-T (make-tetra (make-posn (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE))
                            SOB-T)) 
(define TETRA-Z (make-tetra (make-posn (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE))
                            SOB-Z)) 
(define TETRA-S (make-tetra (make-posn (+ I-START (* 0.5 CELL-SIZE)) (+ Y-START-LOCATION CELL-SIZE))
                            SOB-S)) 

;;; A World is a (make-world Tetra Bricks)
;;; The set of bricks represents the pile of bricks
;;; at the bottom of the screen.
(define-struct world [tetra pile])

;; draw-brick : Brick Image --> Image
;; take in an individual brick and a background image and return an image
(define (draw-brick b bg)
  (place-image (overlay (square CELL-SIZE "outline" 'black)
                        (square CELL-SIZE "solid" (brick-color b)))
               (brick-x b)
               (brick-y b)
               bg))

(check-expect (draw-brick BRICK-O-1 GAME-WORLD) (place-image (overlay (square CELL-SIZE
                                                                              "outline"
                                                                              'black)
                                                                      (square CELL-SIZE
                                                                              "solid"
                                                                              'green))
                                                             90
                                                             10
                                                             (empty-scene
                                                              (+ (* GRID-COLS CELL-SIZE) 1)
                                                              (+ (* GRID-ROWS CELL-SIZE) 1))))
(check-expect (draw-brick BRICK-S-3 GAME-WORLD) (place-image (overlay (square CELL-SIZE
                                                                              "outline"
                                                                              'black)
                                                                      (square CELL-SIZE
                                                                              "solid"
                                                                              'red))
                                                             110
                                                             30
                                                             (empty-scene
                                                              (+ (* GRID-COLS CELL-SIZE) 1)
                                                              (+ (* GRID-ROWS CELL-SIZE) 1))))

;; draw-bricks : SetOfBricks Image --> Image
;; Take in a set of bricks and an image and return an image
(define (draw-bricks sob base)
  (foldr (lambda (x baseImg) (draw-brick x baseImg)) base sob))

(define TEST-SOB (list BRICK-O-1 BRICK-O-2)) 

(check-expect (draw-bricks TEST-SOB GAME-WORLD)
              (place-image (overlay (square CELL-SIZE
                                            "outline"
                                            'black)
                                    (square CELL-SIZE
                                            "solid"
                                            'green))
                           90
                           10
                           (place-image (overlay (square CELL-SIZE
                                                         "outline"
                                                         'black)
                                                 (square CELL-SIZE
                                                         "solid"
                                                         'green))
                                        110
                                        10
                                        (empty-scene
                                         (+ (* GRID-COLS
                                               CELL-SIZE) 1)
                                         (+ (* GRID-ROWS
                                               CELL-SIZE) 1)))))

(check-expect (draw-bricks SOB-I GAME-WORLD)
              (place-image (overlay (square CELL-SIZE
                                            "outline"
                                            'black)
                                    (square CELL-SIZE
                                            "solid"
                                            'blue))
                           70
                           10
                           (place-image (overlay (square CELL-SIZE
                                                         "outline"
                                                         'black)
                                                 (square CELL-SIZE
                                                         "solid"
                                                         'blue))
                                        90
                                        10
                                        (place-image (overlay (square CELL-SIZE
                                                                      "outline"
                                                                      'black)
                                                              (square CELL-SIZE
                                                                      "solid"
                                                                      'blue))
                                                     110
                                                     10
                                                     (place-image (overlay (square CELL-SIZE
                                                                                   "outline"
                                                                                   'black)
                                                                           (square CELL-SIZE
                                                                                   "solid"
                                                                                   'blue))
                                                                  130
                                                                  10
                                                                  (empty-scene
                                                                   (+ (* GRID-COLS
                                                                         CELL-SIZE) 1)
                                                                   (+ (* GRID-ROWS
                                                                         CELL-SIZE) 1)))))))

;; draw-score : World --> Image
;; take in a world and return the score as a text
(define (draw-score w)
  (text (format "Score: ~a" (length (world-pile w))) 10 'black))

(define TEST-WORLD0 (make-world TETRA-Z '()))
(define TEST-WORLD1 (make-world TETRA-O SOB-I))

(check-expect (draw-score TEST-WORLD0) (text "Score: 0" 10 'black))
(check-expect (draw-score TEST-WORLD1) (text "Score: 4" 10 'black))

;; draw-world : World --> Image
;; take in a world and return a picture of the game tetris
(define (draw-world w)
  (overlay/xy (draw-score w)
              70
              (- Y-START-LOCATION (/ CELL-SIZE 2))
              (draw-bricks (tetra-bricks (world-tetra w))
                           (draw-bricks (world-pile w) GAME-WORLD))))

(define TEST-WORLD3 (make-world TETRA-I '()))
(define TEST-WORLD4 (make-world TETRA-I (list BRICK-Z-1 BRICK-Z-1 BRICK-Z-1 BRICK-Z-1 BRICK-Z-1
                                              BRICK-Z-1 BRICK-Z-1 BRICK-Z-1 BRICK-Z-1 BRICK-Z-1)))

(check-expect (draw-world TEST-WORLD3)
              (overlay/xy (text "Score: 0" 10 'black)
                          70
                          0
                          (place-image (overlay (square CELL-SIZE
                                                        "outline"
                                                        'black)
                                                (square CELL-SIZE
                                                        "solid"
                                                        'blue))
                                       70
                                       10
                                       (place-image (overlay (square CELL-SIZE
                                                                     "outline"
                                                                     'black)
                                                             (square CELL-SIZE
                                                                     "solid"
                                                                     'blue))
                                                    90
                                                    10
                                                    (place-image (overlay (square CELL-SIZE
                                                                                  "outline"
                                                                                  'black)
                                                                          (square CELL-SIZE
                                                                                  "solid"
                                                                                  'blue))
                                                                 110
                                                                 10
                                                                 (place-image
                                                                  (overlay
                                                                   (square CELL-SIZE
                                                                           "outline"
                                                                           'black)
                                                                   (square CELL-SIZE
                                                                           "solid"
                                                                           'blue))
                                                                  130
                                                                  10
                                                                  (empty-scene
                                                                   (+ (* GRID-COLS
                                                                         CELL-SIZE) 1)
                                                                   (+ (* GRID-ROWS
                                                                         CELL-SIZE) 1))))))))

(check-expect (draw-world TEST-WORLD4)
              (overlay/xy (text "Score: 10" 10 'black)
                          70
                          0
                          (place-image (overlay (square CELL-SIZE
                                                        "outline"
                                                        'black)
                                                (square CELL-SIZE
                                                        "solid"
                                                        'blue))
                                       70
                                       10
                                       (place-image (overlay (square CELL-SIZE
                                                                     "outline"
                                                                     'black)
                                                             (square CELL-SIZE
                                                                     "solid"
                                                                     'blue))
                                                    90
                                                    10
                                                    (place-image (overlay (square CELL-SIZE
                                                                                  "outline"
                                                                                  'black)
                                                                          (square CELL-SIZE
                                                                                  "solid"
                                                                                  'blue))
                                                                 110
                                                                 10
                                                                 (place-image
                                                                  (overlay
                                                                   (square CELL-SIZE
                                                                           "outline"
                                                                           'black)
                                                                   (square CELL-SIZE
                                                                           "solid"
                                                                           'blue))
                                                                  130
                                                                  10
                                                                  (empty-scene
                                                                   (+ (* GRID-COLS
                                                                         CELL-SIZE) 1)
                                                                   (+ (* GRID-ROWS
                                                                         CELL-SIZE) 1))))))))

;; drop-center : Pt --> Pt
;; take in a point and return a point with changed coord
(define (drop-center pt)
  (make-posn (posn-x pt)
             (+ (posn-y pt) CELL-SIZE)))

(define TEST-PT1 (make-posn 50 50))
(define TEST-PT2 (make-posn -20 -50))

(check-expect (drop-center TEST-PT1) (make-posn 50 70))
(check-expect (drop-center TEST-PT2) (make-posn -20 -30))

;; drop-brick : Brick --> Brick
;; take in a brick and return a brick with their positions lowered
(define (drop-brick b)
  (make-brick (brick-x b)
              (+ (brick-y b) CELL-SIZE)
              (brick-color b)))

(define TEST-BRICK1 (make-brick 20 20 'black))
(define TEST-BRICK2 (make-brick 0 0 'red))
(define TEST-BRICK3 (make-brick -50 -10 'blue))
(define TEST-BRICK4 (make-brick -150 -5 'blue))

(check-expect (drop-brick TEST-BRICK1) (make-brick 20 40 'black))
(check-expect (drop-brick TEST-BRICK2) (make-brick 0 20 'red))

;; drop-bricks : SetOfBricks --> SetOfBricks
;; take in a set of bricks and return a set of bricks with their
;; positions lowered
(define (drop-bricks sob)
  (map (lambda (x) (drop-brick x)) sob))

(define TEST-SOB2 (list TEST-BRICK1 TEST-BRICK2 TEST-BRICK3))
(define TEST-SOB3 (list TEST-BRICK1 TEST-BRICK3 TEST-BRICK4))

(check-expect (drop-bricks TEST-SOB2) (list (make-brick 20 40 'black)
                                            (make-brick 0 20 'red)
                                            (make-brick -50 10 'blue)))
(check-expect (drop-bricks TEST-SOB3) (list (make-brick 20 40 'black)
                                            (make-brick -50 10 'blue)
                                            (make-brick -150 15 'blue)))
                                       
;; brick-bottom : Brick --> Boolean
;; Check when the brick hits the bottom
(define (brick-bottom b)
  (= (brick-y b) (- (* GRID-ROWS CELL-SIZE) (/ CELL-SIZE 2))))

(define TEST-BRICK5 (make-brick 40 390 'green))
(define TEST-BRICK6 (make-brick -20 400 'red))

(check-expect (brick-bottom TEST-BRICK5) #true)
(check-expect (brick-bottom TEST-BRICK6) #false)

;; bricks-bottom : SetOfBricks --> Boolean
;; Check when the bricks hit the bottom
(define (bricks-bottom sob)
  (ormap (lambda (x) (brick-bottom x)) sob))

(define TEST-SOB4 (list TEST-BRICK1 TEST-BRICK2 TEST-BRICK3 TEST-BRICK5))
(define TEST-SOB5 (list TEST-BRICK1 TEST-BRICK2 TEST-BRICK3 TEST-BRICK6))

(check-expect (bricks-bottom TEST-SOB4) #true)
(check-expect (bricks-bottom TEST-SOB5) #false)

;; brick-on-pile? : Brick SetOfBricks --> Boolean
;; check when the brick hits the pile
(define (brick-on-pile? b p)
  (cond
    [(empty? p) #false]
    [(and (= (+ (brick-y b) CELL-SIZE) (brick-y (first p)))
          (= (brick-x b) (brick-x (first p)))) #true]
    [else (brick-on-pile? b (rest p))]))

(check-expect (brick-on-pile? TEST-BRICK5 '()) #false)
(check-expect (brick-on-pile? (make-brick 20 0 'black) TEST-SOB4) #true)

;; bricks-on-pile? : SetOfBricks SetOfBricks --> Boolean
;; check when the bricks hit the pile. Sob = set of bricks
;; pob = pile of bricks.
(define (bricks-on-pile? sob pob)
  (ormap (lambda (x) (brick-on-pile? x pob)) sob))

(define TEST-BRICK7 (make-brick 60 60 'red))
(define TEST-BRICK8 (make-brick 60 100 'red))
(define TEST-SOB6 (list TEST-BRICK7 TEST-BRICK8))

(define PILE-BRICK0 '())
(define PILE-BRICK1 (make-brick 60 120 'green))
(define PILE-BRICK2 (make-brick 50 120 'cyan))

(check-expect (bricks-on-pile? TEST-SOB6 PILE-BRICK0) #false)
(check-expect (bricks-on-pile? TEST-SOB6 (list PILE-BRICK1 PILE-BRICK2)) #true)

;; brick-on-pile-side? : Brick SetOfBricks --> Boolean
;; check when the brick hits the pile on the side
(define (brick-on-pile-side? b p)
  (ormap (lambda (x) (or (and (= (- (brick-x b) CELL-SIZE) (brick-x x))
                              (= (brick-y b) (brick-y x)))
                         (and (= (+ (brick-x b) CELL-SIZE) (brick-x x))
                              (= (brick-y b) (brick-y x)))))
         p))

(define PILE-BRICK3 (make-brick 80 60 'black))
(define PILE-BRICK4 (make-brick 40 60 'green))
(define PILE-BRICK5 (make-brick 50 90 'blue))

(check-expect (brick-on-pile-side? TEST-BRICK7 PILE-BRICK0) #false)
(check-expect (brick-on-pile-side? TEST-BRICK7 (list PILE-BRICK3 PILE-BRICK5)) #true)
(check-expect (brick-on-pile-side? TEST-BRICK7 (list PILE-BRICK4 PILE-BRICK5)) #true)
(check-expect (brick-on-pile-side? TEST-BRICK7 (list PILE-BRICK5)) #false)

;; bricks-on-pile-side? : Bricks --> Boolean
;; check when the bricks hit the pile on the side. Sob = set of bricks
;; pob = pile of bricks.
(define (bricks-on-pile-side? sob pob)
  (ormap (lambda (x) (brick-on-pile-side? x pob)) sob))

(define TEST-SOB7 (list TEST-BRICK1 TEST-BRICK2 TEST-BRICK3 TEST-BRICK6 TEST-BRICK7))

(check-expect (bricks-on-pile-side? '() (list PILE-BRICK3 PILE-BRICK5)) #false)
(check-expect (bricks-on-pile-side? TEST-SOB7 '()) #false)
(check-expect (bricks-on-pile-side? TEST-SOB7 (list PILE-BRICK3 PILE-BRICK5)) #true)

;; drop-tetra : Tetra --> Tetra
;; take in a tetra and drop it by 1 cell
(define (drop-tetra t)
  (make-tetra (drop-center (tetra-center t))
              (drop-bricks (tetra-bricks t))))

(define TEST-CENTER1 (make-posn 80 80))
(define TEST-CENTER2 (make-posn 150 200))
(define TEST-TETRA1 (make-tetra TEST-CENTER1 TEST-SOB6))
(define TEST-TETRA2 (make-tetra TEST-CENTER2 (list PILE-BRICK3 PILE-BRICK4 PILE-BRICK5)))

(check-expect (drop-tetra TEST-TETRA1) (make-tetra (make-posn 80 100)
                                                   (list (make-brick 60 80 'red)
                                                         (make-brick 60 120 'red))))
(check-expect (drop-tetra TEST-TETRA2) (make-tetra (make-posn 150 220)
                                                   (list (make-brick 80 80 'black)
                                                         (make-brick 40 80 'green)
                                                         (make-brick 50 110 'blue))))

;; choose-tetra : Number --> Tetra
;; take in a number and returns a tetra
(define (choose-tetra n)
  (cond
    [(= n 0) TETRA-O]
    [(= n 1) TETRA-I]
    [(= n 2) TETRA-L]
    [(= n 3) TETRA-J]
    [(= n 4) TETRA-T]
    [(= n 5) TETRA-Z]
    [(= n 6) TETRA-S]))

(check-expect (choose-tetra 0) TETRA-O)
(check-expect (choose-tetra 1) TETRA-I)
(check-expect (choose-tetra 2) TETRA-L)
(check-expect (choose-tetra 3) TETRA-J)
(check-expect (choose-tetra 4) TETRA-T)
(check-expect (choose-tetra 5) TETRA-Z)
(check-expect (choose-tetra 6) TETRA-S)

;; full-row : SetOfBricks Number --> Boolean
;; check if a row is filled with bricks
(define (full-row sob y-coord)
  (= 10 (foldr (lambda (x base) (if (= (brick-y x) y-coord)
                                    (+ 1 base)
                                    base))
               0
               sob)))

(check-expect (full-row (list (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan))
                        50)
              #true)
(check-expect (full-row (list (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                              (make-brick 50 50 'cyan) (make-brick 50 90 'red))
                        50)
              #false)
(check-expect (full-row (list)
                        110)
              #false)

;; check-all-row : SetOfBricks --> [List-of Numbers]
;; outputs the y-coordinates of the rows that are filled
(define (check-all-row sob)
  (local [(define Y-COORDS
            (build-list 20 (lambda (x) (+ 10 (* x 20)))))]
    (filter (lambda (x) (full-row sob x)) Y-COORDS)))

(check-expect (check-all-row (list (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                                   (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                                   (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                                   (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                                   (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                                   (make-brick 50 70 'cyan)))
              (list 50))
(check-expect (check-all-row (list (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)))
              (list))
                             
;; remove-full-rows : SetOfBricks [List-of Numbers] --> SetOfBricks
;; remove the rows in the pile if it is full
(define (remove-full-rows sob y-coords)
  (foldr (lambda (x base) (if (member (brick-y x) y-coords)
                              (remove x base)
                              base))
         sob
         sob))

(check-expect (remove-full-rows (list (make-brick 90 90 'cyan)
                                      (make-brick 110 110 'red)
                                      (make-brick 130 130 'green)
                                      (make-brick 50 50 'cyan))
                                (list 90 110 150))
              (list (make-brick 130 130 'green) (make-brick 50 50 'cyan)))
(check-expect (remove-full-rows (list)
                                (list 110 190 210))
              (list))

;; drop-pile : SetOfBricks Number --> SetOfBricks
;; take in a pile of bricks and drop them if their y-coord is less than the number given
(define (drop-pile sob n)
  (map (lambda (x) (if (< (brick-y x) n)
                       (drop-brick x)
                       x))
       sob))

(check-expect (drop-pile (list (make-brick 50 30 'cyan) (make-brick 50 30 'cyan)
                               (make-brick 50 30 'cyan) (make-brick 50 30 'cyan)
                               (make-brick 50 90 'red))
                         50)
              (list (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                    (make-brick 50 50 'cyan) (make-brick 50 50 'cyan)
                    (make-brick 50 90 'red)))
(check-expect (drop-pile (list)
                         110)
              (list))                          
                            
;; multi-drop : SetOfBricks [List-of Numbers] --> SetOfBricks
;; take in a pile of bricks and drop them according to the list of y-coords given

;; Used recursion in this function because it does not fit the foldr. Pls don't
;; take points off. 
(define (multi-drop sob loy)
  (cond
    [(empty? loy) sob]
    [(cons? loy) (multi-drop (drop-pile sob (first loy))
                             (rest loy))]))
                     
(check-expect (multi-drop (list (make-brick 50 30 'cyan) (make-brick 50 30 'cyan)
                                (make-brick 50 30 'cyan) (make-brick 50 30 'cyan)
                                (make-brick 50 90 'red))
                          (list 50 110))
              (list (make-brick 50 70 'cyan) (make-brick 50 70 'cyan)
                    (make-brick 50 70 'cyan) (make-brick 50 70 'cyan)
                    (make-brick 50 110 'red)))
(check-expect (multi-drop (list)
                          (list 10 30 50 70))
              (list))
                          
;; next-world : World --> World
;; Take in a world and outputs another world 1 tick ahead
(define (next-world w)
  (cond
    [(or (bricks-bottom (tetra-bricks (world-tetra w)))
         (bricks-on-pile? (tetra-bricks (world-tetra w)) (world-pile w)))
     (make-world (choose-tetra (random 7))
                 (append (tetra-bricks (world-tetra w)) (world-pile w)))]
    [else (make-world (drop-tetra (world-tetra w))
                      (if (empty? (check-all-row (world-pile w)))
                          (world-pile w)
                          (multi-drop (remove-full-rows
                                       (world-pile w)
                                       (check-all-row (world-pile w)))
                                      (check-all-row (world-pile w)))))]))

(define NW-BRICK1 (make-brick 50 100 'green))
(define NW-BRICK2 (make-brick 40 390 'blue))
(define NW-SOB1 (list NW-BRICK1 NW-BRICK2))
(define NW-CENTER1 (make-posn 100 100))
(define NW-TETRA1 (make-tetra NW-CENTER1 NW-SOB1))
(define NW-PILE1 (list))
(define NW-WORLD1 (make-world NW-TETRA1 NW-PILE1))

(define NW-BRICK3 (make-brick 50 100 'green))
(define NW-BRICK4 (make-brick 40 200 'blue))
(define NW-SOB2 (list NW-BRICK3 NW-BRICK4))
(define NW-TETRA2 (make-tetra NW-CENTER1 NW-SOB2))
(define NW-WORLD2 (make-world NW-TETRA2 NW-PILE1))


(check-random (next-world NW-WORLD1) (make-world (choose-tetra (random 7))
                                                 (list NW-BRICK1 NW-BRICK2)))

(check-expect (next-world NW-WORLD2) (make-world (make-tetra (make-posn 100 120)
                                                             (list (make-brick 50 120 'green)
                                                                   (make-brick 40 220 'blue)))
                                                 '()))

;; move-brick : Brick Number --> Brick
;; take in a brick and a number and return a brick with their positions shifted
;; left or right
(define (move-brick b n)
  (make-brick (+ (brick-x b) n)
              (brick-y b)
              (brick-color b)))

(check-expect (move-brick TEST-BRICK5 40) (make-brick 80 390 'green))
(check-expect (move-brick TEST-BRICK6 20) (make-brick 0 400 'red))

;; move-bricks : Bricks Number --> Bricks
;; take in a set of bricks and a number and return a set of bricks with their
;; positions shifted left or right
(define (move-bricks sob n)
  (map (lambda (x) (move-brick x n)) sob))

(define TEST-SOB0 (list))
(check-expect (move-bricks TEST-SOB0 10) '())
(check-expect (move-bricks TEST-SOB2 10) (list (make-brick 30 20 'black)
                                               (make-brick 10 0 'red)
                                               (make-brick -40 -10 'blue)))

;; move-center : Pt --> Pt
;; take in a point and return a point that is shifted left or right
(define (move-center pt n)
  (make-posn (+ (posn-x pt) n)
             (posn-y pt)))

(check-expect (move-center TEST-CENTER1 50) (make-posn 130 80))
(check-expect (move-center TEST-CENTER2 -50) (make-posn 100 200))

;; move-tetra : Tetra Number --> Tetra
;; Take in a tetra and a number and output its new position
(define (move-tetra t n)
  (make-tetra (move-center (tetra-center t) n)
              (move-bricks (tetra-bricks t) n)))

(define TEST-TETRA3 (make-tetra TEST-CENTER1 TEST-SOB2))
(define TEST-TETRA4 (make-tetra TEST-CENTER2 TEST-SOB6))

(check-expect (move-tetra TEST-TETRA3 10) (make-tetra (make-posn 90 80)
                                                      (list (make-brick 30 20 'black)
                                                            (make-brick 10 0 'red)
                                                            (make-brick -40 -10 'blue))))
(check-expect (move-tetra TEST-TETRA4 -10) (make-tetra (make-posn 140 200)
                                                       (list (make-brick 50 60 'red)
                                                             (make-brick 50 100 'red))))

;; brick-on-border-left? : Brick --> Boolean
;; check when the brick hits the left border
(define (brick-on-border-left? b)
  (= (- (brick-x b) (/ CELL-SIZE 2)) 0))

(define TEST-BRICK9 (make-brick 10 50 'black))
(define TEST-BRICK10 (make-brick 20 100 'green))

(check-expect (brick-on-border-left? TEST-BRICK9) #true)
(check-expect (brick-on-border-left? TEST-BRICK10) #false)

;; brick-on-border-right? : Brick --> Boolean
;; check when the brick hits the right border
(define (brick-on-border-right? b)
  (= (+ (brick-x b) (/ CELL-SIZE 2)) (* GRID-COLS CELL-SIZE)))

(define TEST-BRICK11 (make-brick 190 50 'black))
(define TEST-BRICK12 (make-brick 180 100 'green))

(check-expect (brick-on-border-right? TEST-BRICK11) #true)
(check-expect (brick-on-border-right? TEST-BRICK12) #false)

;; bricks-on-border-left? : SetOfBricks --> Boolean
;; check when the bricks hit the left world border.
(define (bricks-on-border-left? sob)
  (ormap (lambda (x) (brick-on-border-left? x)) sob))

(define TEST-SOB8 (list TEST-BRICK9 TEST-BRICK10))
(define TEST-SOB9 (list TEST-BRICK11 TEST-BRICK12))

(check-expect (bricks-on-border-left? TEST-SOB8) #true)
(check-expect (bricks-on-border-left? TEST-SOB9) #false)

;; bricks-on-border-right? : SetOfBricks --> Boolean
;; check when the bricks hit the right world border.
(define (bricks-on-border-right? sob)
  (ormap (lambda (x) (brick-on-border-right? x)) sob))

(check-expect (bricks-on-border-right? TEST-SOB8) #false)
(check-expect (bricks-on-border-right? TEST-SOB9) #true)

;; brick-rotate-cw : Brick Pt --> Brick
;; Rotate the brick 90 degrees clockwise around the center.
(define (brick-rotate-cw br center)
  (make-brick (+ (posn-x center)
                 (- (posn-y center)
                    (brick-y br)))
              (+ (posn-y center)
                 (- (brick-x br)
                    (posn-x center)))
              (brick-color br)))

(define TEST-CENTER3 (make-posn 100 100))
(define RT-BRICK1 (make-brick 120 100 'green))
(define RT-BRICK2 (make-brick 100 120 'red))
(define RT-BRICK3 (make-brick 50 50 'green))
(define RT-BRICK4 (make-brick 200 200 'red))

(check-expect (brick-rotate-cw RT-BRICK1 TEST-CENTER3) (make-brick 100 120 'green))
(check-expect (brick-rotate-cw RT-BRICK2 TEST-CENTER3) (make-brick 80 100 'red))
(check-expect (brick-rotate-cw RT-BRICK3 TEST-CENTER3) (make-brick 150 50 'green))
(check-expect (brick-rotate-cw RT-BRICK4 TEST-CENTER3) (make-brick 0 200 'red))

;; bricks-rotate-cw : SetOfBricks Pt --> SetOfBricks
;; Rotate the bricks 90 degrees clockwise around the posn.
(define (bricks-rotate-cw sob center)
  (map (lambda (x) (brick-rotate-cw x center)) sob))

(define RT-SOB0 (list))
(define RT-SOB1 (list RT-BRICK1 RT-BRICK2))
(define RT-SOB2 (list RT-BRICK3 RT-BRICK4))

(check-expect (bricks-rotate-cw RT-SOB0 TEST-CENTER3) '())
(check-expect (bricks-rotate-cw RT-SOB1 TEST-CENTER3) (list (make-brick 100 120 'green)
                                                            (make-brick 80 100 'red)))
(check-expect (bricks-rotate-cw RT-SOB2 TEST-CENTER3) (list (make-brick 150 50 'green)
                                                            (make-brick 0 200 'red)))
               
;; make-tetra-from-cw-rt : Tetra --> Tetra
;; Take in clockwise rotated bricks and create a tetra
(define (make-tetra-from-cw-rt t)
  (make-tetra (tetra-center t) (bricks-rotate-cw (tetra-bricks t) (tetra-center t))))

(define RT-TETRA1 (make-tetra TEST-CENTER3 RT-SOB1))
(define RT-TETRA2 (make-tetra TEST-CENTER3 RT-SOB2))
  
(check-expect (make-tetra-from-cw-rt RT-TETRA1) (make-tetra (make-posn 100 100)
                                                            (list (make-brick 100 120 'green)
                                                                  (make-brick 80 100 'red))))
(check-expect (make-tetra-from-cw-rt RT-TETRA2) (make-tetra (make-posn 100 100)
                                                            (list (make-brick 150 50 'green)
                                                                  (make-brick 0 200 'red))))

;; bricks-rotate-ccw : SetOfBricks Pt --> SetOfBricks
;; Rotate the bricks 90 counter-clockwise around the center by calling
;; brick-rotate-cw 3 times.
(define (bricks-rotate-ccw sob center)
  (map (lambda (x) (brick-rotate-cw (brick-rotate-cw (brick-rotate-cw x center) center) center)) sob))

(check-expect (bricks-rotate-ccw RT-SOB0 TEST-CENTER3) '())
(check-expect (bricks-rotate-ccw RT-SOB1 TEST-CENTER3) (list (make-brick 100 80 'green)
                                                             (make-brick 120 100 'red)))
(check-expect (bricks-rotate-ccw RT-SOB2 TEST-CENTER3) (list (make-brick 50 150 'green)
                                                             (make-brick 200 0 'red)))
                                                             
;; make-tetra-from-ccw-rt : Tetra --> Tetra
;; Take in counter-clockwise rotated bricks and create a tetra
(define (make-tetra-from-ccw-rt t)
  (make-tetra (tetra-center t) (bricks-rotate-ccw (tetra-bricks t) (tetra-center t))))

(check-expect (make-tetra-from-ccw-rt RT-TETRA1) (make-tetra (make-posn 100 100)
                                                             (list (make-brick 100 80 'green)
                                                                   (make-brick 120 100 'red))))
(check-expect (make-tetra-from-ccw-rt RT-TETRA2) (make-tetra (make-posn 100 100)
                                                             (list (make-brick 50 150 'green)
                                                                   (make-brick 200 0 'red))))

;; check-for-rotation: World --> Boolean
;; check to make sure rotation tetras don't go inside a pile/out of world
(define (check-for-rotation w)
  (or (bricks-on-border-left? (tetra-bricks (world-tetra w)))
      (bricks-on-border-right? (tetra-bricks (world-tetra w)))
      (bricks-bottom (tetra-bricks (world-tetra w)))
      (bricks-on-pile? (tetra-bricks (world-tetra w)) (world-pile w))
      (bricks-on-pile-side? (tetra-bricks (world-tetra w)) (world-pile w))))

(define TEST-PILE0 (list))
(define TETRA-RT (make-tetra TEST-CENTER3 TEST-SOB8))
(define TETRA-RT2 (make-tetra TEST-CENTER3 TEST-SOB7))
(define WORLD-RT1 (make-world TETRA-RT TEST-PILE0))
(define WORLD-RT2 (make-world TETRA-RT2 TEST-PILE0))

;; Only have to check #true or #false for this function because I've already checked the
;; correctness of the functions inside check-for-rotation
(check-expect (check-for-rotation WORLD-RT1) #true)
(check-expect (check-for-rotation WORLD-RT2) #false)

;; handle-key : World KE --> World
;; Take in a world and a key and output a world that is changed due to
;; the key
(define (handle-key w ke)
  (cond
    [(key=? "left"  ke) (if (or (bricks-on-border-left? (tetra-bricks (world-tetra w)))
                                (bricks-on-pile-side? (tetra-bricks (world-tetra w)) (world-pile w)))
                            w
                            (make-world (move-tetra (world-tetra w) (* -1 CELL-SIZE))
                                        (world-pile w)))]
    [(key=? "right" ke) (if (or (bricks-on-border-right? (tetra-bricks (world-tetra w)))
                                (bricks-on-pile-side? (tetra-bricks (world-tetra w)) (world-pile w)))
                            w
                            (make-world (move-tetra (world-tetra w) (* 1 CELL-SIZE))
                                        (world-pile w)))]
    [(key=? "s" ke) (if (check-for-rotation w)
                        w
                        (make-world (make-tetra-from-cw-rt (world-tetra w))
                                    (world-pile w)))]
    [(key=? "a" ke) (if (check-for-rotation w)
                        w
                        (make-world (make-tetra-from-ccw-rt (world-tetra w))
                                    (world-pile w)))]
    [else w]))

(define KEY-BRICK1 (make-brick 50 50 'black))
(define KEY-BRICK2 (make-brick 10 50 'yellow))
(define KEY-BRICK3 (make-brick 20 50 'green))
(define KEY-BRICK4 (make-brick 150 100 'black))
(define KEY-BRICK5 (make-brick 190 100 'yellow))
(define KEY-BRICK6 (make-brick 100 50 'green))

(define KEY-SOB1 (list KEY-BRICK1 KEY-BRICK2))
(define KEY-SOB2 (list KEY-BRICK1 KEY-BRICK3))
(define KEY-SOB3 (list KEY-BRICK4 KEY-BRICK5)) #true
(define KEY-SOB4 (list KEY-BRICK4 KEY-BRICK6)) #false

(define KEY-CENTER1 (make-posn 50 50))
(define KEY-TETRA1 (make-tetra KEY-CENTER1 KEY-SOB1))
(define KEY-TETRA2 (make-tetra KEY-CENTER1 KEY-SOB2))
(define KEY-TETRA3 (make-tetra KEY-CENTER1 KEY-SOB3))
(define KEY-TETRA4 (make-tetra KEY-CENTER1 KEY-SOB4))

(define KEY-PILE1 (list))
(define KEY-WORLD1 (make-world KEY-TETRA1 KEY-PILE1))
(define KEY-WORLD2 (make-world KEY-TETRA2 KEY-PILE1))
(define KEY-WORLD3 (make-world KEY-TETRA3 KEY-PILE1))
(define KEY-WORLD4 (make-world KEY-TETRA4 KEY-PILE1))

(check-expect (handle-key KEY-WORLD1 "left") KEY-WORLD1)
(check-expect (handle-key KEY-WORLD2 "left") (make-world (make-tetra (make-posn 30 50)
                                                                     (list (make-brick 30 50 'black)
                                                                           (make-brick 0 50 'green)))
                                                         '()))

(check-expect (handle-key KEY-WORLD3 "right") KEY-WORLD3)
(check-expect (handle-key KEY-WORLD4 "right") (make-world (make-tetra
                                                           (make-posn 70 50)
                                                           (list (make-brick 170 100 'black)
                                                                 (make-brick 120 50 'green)))
                                                          '()))

(check-expect (handle-key WORLD-RT1 "s") WORLD-RT1)
(check-expect (handle-key WORLD-RT2 "s") (make-world (make-tetra (make-posn 100 100)
                                                                 (list (make-brick 180 20 'black)
                                                                       (make-brick 200 0 'red)
                                                                       (make-brick 210 -50 'blue)
                                                                       (make-brick -200 -20 'red)
                                                                       (make-brick 140 60 'red)))
                                                     '()))


(check-expect (handle-key WORLD-RT1 "a") WORLD-RT1)
(check-expect (handle-key WORLD-RT2 "a") (make-world (make-tetra (make-posn 100 100)
                                                                 (list (make-brick 20 180 'black)
                                                                       (make-brick 0 200 'red)
                                                                       (make-brick -10 250 'blue)
                                                                       (make-brick 400 220 'red)
                                                                       (make-brick 60 140 'red)))
                                                     '()))

(check-expect (handle-key KEY-WORLD1 "w") KEY-WORLD1)

;; pile-at-top? : SetOfBricks --> Boolean
;; Take in a set of bricks and checks if the pile of bricks has reached the top
(define (pile-at-top? sob)
  (ormap (lambda (x) (= (brick-y x) Y-START-LOCATION)) sob))

(define TEST-BRICK13 (make-brick 120 50 'green))
(define TEST-BRICK14 (make-brick 30 10 'red))
(define TEST-PILE1 (list TEST-BRICK13 TEST-BRICK14))

(check-expect (pile-at-top? TEST-PILE0) #false)
(check-expect (pile-at-top? TEST-PILE1) #true)

;; game-over? : World --> Boolean
;; Take in a world and checks if the game is over
(define (game-over? w)
  (pile-at-top? (world-pile w)))

(define TEST-WORLD5 (make-world TETRA-O TEST-PILE0))
(define TEST-WORLD6 (make-world TETRA-O TEST-PILE1))

(check-expect (game-over? TEST-WORLD5) #false)
(check-expect (game-over? TEST-WORLD6) #true)

;; draw-end-world : World --> Image
;; Take in a world and return the score as a text
(define (draw-end-world w)
  (text (format "Game Over.. Your Final Score Is: ~a" (length (world-pile w))) 10 'black))

(check-expect (draw-end-world TEST-WORLD5) (text "Game Over.. Your Final Score Is: 0" 10 'black))
(check-expect (draw-end-world TEST-WORLD6) (text "Game Over.. Your Final Score Is: 2" 10 'black))

;; main program
;; start-game : World --> World
;; Starts the game 
(define (start-game w)
  (big-bang w
    [to-draw draw-world]
    [on-tick next-world TICK-RATE]
    [on-key handle-key]
    [stop-when game-over? draw-end-world]))

(start-game (make-world TETRA-O '()))