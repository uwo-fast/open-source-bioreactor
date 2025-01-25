/**
 * @file _config.scad
 * @brief Configuration file to aid the development OpenSCAD designs in preview mode
 * @author Cameron K. Brooks
 */

zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview
$fn = $preview ? 32 : 128;