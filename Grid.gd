extends Node2D

# pixels per chunck, each chunk that they will be able to exist on is either 32 or 64 pixels x/y
var tile_size_gl = 64
var tile_size_midpoint_gl = 32

# setting a default size for the grid (60 being 10 chunks wide and 6 chunks deep)
var grid_size_gl = 10
var grid = []
