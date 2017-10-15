A MATLAB program capable of composing short melody phrases. It is able to work with specified microtonal scales.

The melody generation process initially creates a rhythm structure using a Markov chain, to which pitches are subsequently assigned. Information for the Markov chain is collected from a small library of ~30 melodies. Pitches are selected using a genetic algorithm with fitness function criteria that compare the output melody with compiled distributions from either the melody library or else may be manually input.

It was developed as part of an electronic engineering Masters project. The thesis is also included - MMG final.pdf.
