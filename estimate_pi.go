package main

import (
	"fmt"
	"math"
	"math/rand"
	"time"
)

func main() {
	pointsToCalculate := 100000000
	pointsInCircle := 0
	pointsInTotal := 0
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1)
	for i := 0; i < pointsToCalculate; i++ {
		x := r1.Float64()
		y := r1.Float64()
		distance := math.Pow(x, 2) + math.Pow(y, 2)
		if distance <= 1 {
			pointsInCircle++
		}
		pointsInTotal++
	}
	estimate := 4 * float64(pointsInCircle) / float64(pointsInTotal)
	fmt.Printf("Pi was estimated to be %f with %v data points\n", estimate, pointsToCalculate)
}
