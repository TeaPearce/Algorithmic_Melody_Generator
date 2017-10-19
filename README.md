# Algorithmic microtonal melody generator

## Intro

A MATLAB program capable of composing short melody phrases. It is able to work with custom scales (e.g. 12TET, 19TET...).

Developed as part of an electronic engineering Masters project. The [thesis](MMG%20final.pdf) is also included.

## Melody generation process

The melody generation process initially creates a rhythm structure using a Markov chain, to which pitches are subsequently assigned. Information for the Markov chain is collected from a small library of ~30 melodies (included). Pitches are assigned using a genetic algorithm with fitness function criteria that compare the output melody with compiled distributions from either the melody library or else may be manually input.

## Statistical analysis

Much of the work in the project was aimed at discovering statistically significant patterns within human-composed melodies. Hypotheses were manually generated and testedf for significance. See [thesis](MMG%20final.pdf) for full details.


## Project status

I am no longer actively developing this. Feel free to fork and experiment.
