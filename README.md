1. Introduction

“To live is to be musical, starting with the blood dancing in your veins. Everything living has a rhythm. Do you feel your music?” 
― Michael Jackson

Throughout the history of mankind, the perception, combination, and creation of sounds have always fascinated people. Sound and silence, harmony and cacophony are all vehicles of music to express the inexpressible. 

However, what underlies the formation of this art? Early philosopher and mathematician Pythagoras postulates that music is inseparable from numbers and patterns. Pitches can be represented in frequencies, while rhythms can be represented in durations. If we can extract the “algorithms” behind music, can we also automate musical composition with little human intervention? 

In this project, we manage to combine our love for music and programming by simulating the composition of Jazz music using FPGA. SoloMaster is an automated composition system whose outcome can also be heard by the user. In SoloMaster, initiation is controlled by a reset switch, and speed adjustment is controlled another 3 switches. 

From various researches, it is shown that patterns governing the sequence of pitches and rhythms in Jazz music can be modeled by a Markov Chain [1]. By using these results, we can possibly teach a program to synthesize Jazz music on its own, which is what SoloMaster does. SoloMaster composes and plays out Jazz music through two stages. In the first stage, SoloMaster generates a sequence of pitches, and in the second stage plays it out in an improvisational fashion. 


2. The Description of  Design

Figure: Block Diagram of SoloMaster
     2.1 Algorithm for Composition
The composition is done through an algorithm which produces a sequence of notes based on previous notes. The algorithm contains three components - 1) a first-order stochastic matrix which describes possibilities of the occurrence of each note based on a previous note, 2) a linear feedback shift register for random number generation, and 3) and a register for storing the next note to be produced. The new note signal is also forwarded to the Audio Controller module to be played out. 

The algorithm is implemented in module note_generator. The timing of the module depends on an output of the Audio Controller module. Turning on the reset switch SW[0] initializes the module by giving the algorithm a note to start with and sets the algorithm in motion. Whenever a new note (cur_note) is conceived, the module selects a corresponding probability vector (pool) from the matrix for the current note using a case statement. The probability vector is a pool of possible next notes with weighted occurrences. At each rising clock edge, the linear feedback shift register produces a random number which then binds to a specific note (next_note) in the probability vector pool. The next_note at this moment becomes the new cur_note, and the register stores it in. Then the cycle repeats.

The strength of this algorithm is that the matrix gives great flexibility to producing music of different genres. The matrix can be modified and filled with different combinations of pitches according to rules of other genres, while the other parts of the module still remain the same. 

    2.2 Audio Controller
Our project used the audio controller [3] to produce sound. For the jazz style, we chose 15 notes in A7 chord within three octaves. Since different note had its unique frequency[4], we used 15 different counters to achieve the desired frequencies. When the note_ generator module passed the binary representation of the current note, the audio controller would match this note with its corresponding frequency and produce its sound accordingly.
The switches on the FPGA were used for user to select. In our project, user could start/resume and pause the music via switch[0]. Furthermore, user could change the tempo of the song before and during the song is being played. We set three different tempo levels, which were 80 beats per minute, 90 beats per minute and 100 beats per minute. Switch [9], [8] and [7] were used to accomplish this function.  Besides tempo for the whole song, the time for each notes was different. According to the algorithm, the notes could be quarter notes, eighth notes, sixteenth notes and rest, which composed to a real song.  

3. Report On Success
     3.1 Successful Parts

The answer to this is affirmative. SoloMaster succeeds to compose and play the music at a specified time and tempo. When the reset switch is turned on, SoloMaster plays jazz spontaneously at the default tempo, which is 80 beats per minute. When speed is adjusted using switches 7-9, SoloMaster speeds up or slows down the music accordingly. When the reset switch is turned off, SoloMaster halts and waits for the next activation signal. Musically, the pitches and rhythms are very close to jazz style. Jazz music is characterized by the element of surprise in the improvisation and a swinging feeling. SoloMaster uses the A7 chord, which is common in Jazz music. The randomized selection of notes in the chord makes the next note unpredictable, thus giving the audience a feeling of anticipation. Swing, formally known as notes inégales, is accomplished by varying the length of each note when it is played. Therefore, in terms of composing and playing the music, SoloMaster is quite sufficient. 
 
     3.2 For Parts that Did Not Work
     
According to what we have described above, all of the main parts of our project, such as composition  and audio playing, are functional. Beside those, there were two functionalities that we had left to do and that can be implemented to improve the project. Back in the scoping stage, we wanted to augment the project with a VGA display which would make the project more engaging. The screen would show the speed that the user selected, and each note in numbered musical notation. That is, while each note was composed by the algorithm we provided, the user could not only hear the song, but also see what the song is. We ran out of time when we tried to implement the display part, so we did not included it in the final demonstration for TA. Furthermore, we were not satisfied that our project could only compose jazz. In our plan, it could also compose many other type of music, such as classical, R&B, and rock n’ roll. To achieve this function, it only needed to add more stochastic matrices for each type of music, like the note_generation module we implemented for jazz. Due to the same reason, inadequate time management, this part was not fulfilled at the end.
 
4. Review and Improvement

When we implemented the project, audio controller was the one of difficulties that we faced. At the beginning, the files for audio controller could not compile. Therefore, we opted to connect FPGA to an external speaker, exporting the clock signal to a breadboard. It did not work either, because the clock signal could not pass through the wire. Then we reverted to make the audio controller work. This process was very time-consuming, so we did not have enough time to implement VGA display and improve the algorithm for composing other types of music. If we were to start the project again, we would manage the time more properly. We definitely would spend more time on implementing the algorithm. Or we could separate the tasks: one person only focused on algorithm and the other person worked on both audio controller and VGA displaying, which could minimize the time.
Another thing we would do is adding more features for user interaction to our project. Composing the song only by the computer was the extraordinary feature of the project. User did not need to do anything during the process of composition, however, in order to increase the usability of SoloMaster, it should compose the song that user liked. To achieve it, we could let the user set some criteria for the song before composing, such as music type, tempo, tonality, and sound effect. Therefore, the user would love the song which is customized for him.

5. Reference 

[1] Franz, David M. ‘Markov Chains as Tools for Jazz Improvisation Analysis’. Virginia Polytechnic Institute and State University, Virginia. April 23, 1998. [Online]. Available: http://scholar.lib.vt.edu/theses/available/etd-61098-131249/unrestricted/dmfetd.pdf
[2]  Williams, Martin. "Defining Jazz." The Jazz Tradition. New York: Oxford UP, 1970. Print. 
[3]Eecg.utoronto.ca, 'Audio Controller', 2015. [Online]. Available: http://www.eecg.utoronto.ca/~jayar/ece241_08F/AudioVideoCores/audio/audio.html.
[4]Phy.mtu.edu, 'Frequencies of Musical Notes', 2015. [Online]. Available: http://www.phy.mtu.edu/~suits/notefreqs.html.

