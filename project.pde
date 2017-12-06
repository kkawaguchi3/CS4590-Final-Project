import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import be.tarsos.dsp.*;
import javax.sound.sampled.*;
import be.tarsos.dsp.io.jvm.AudioDispatcherFactory;
import be.tarsos.dsp.io.jvm.AudioPlayer;
import be.tarsos.dsp.WaveformSimilarityBasedOverlapAdd.Parameters;
import be.tarsos.dsp.WaveformSimilarityBasedOverlapAdd;


//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions
SamplePlayer song;
ControlP5 p5;
Glide gainGlide;

private AudioDispatcher dispatcher;
private WaveformSimilarityBasedOverlapAdd wsola;
private GainProcessor gain;
private AudioPlayer audioPlayer;
private RateTransposer rateTransposer;
private double sampleRate;
AudioFormat format;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions

  p5 = new ControlP5(this);
  gainGlide = new Glide(ac, 0.0, 50);

  
  p5.addSlider("HeartRate")
    .setPosition(70, 50)
    .setSize(20, 100)
    .setRange(40, 192)
    .setValue(80)
    ;
    
  p5.addButton("PitchShift")
    .setPosition(160, 80)
    .setSize(50,50)
    .activateBy(ControlP5.RELEASE);
    ;
    
  p5.addButton("TimeStretch")
    .setPosition(230, 80)
    .setSize(50,50)
    .activateBy(ControlP5.RELEASE);
    ;
    
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}

public static double centToFactor(double cents){
    return 1 / Math.pow(Math.E,cents*Math.log(2)/1200/Math.log(Math.E)); 
}


public void HeartRate(int newgain) {
  p5.getController("HeartRate").setBroadcast(false);
  p5.getController("HeartRate").setValue(newgain);
  p5.getController("HeartRate").setBroadcast(true);
  println("Gain slider pressed " + p5.getController("HeartRate").getValue());
}

public void PitchShift() {
  println("PitchShift pressed");

  try { 
    if (dispatcher != null){
      dispatcher.stop();
    }
    
    File inputFile = new File("/Users/kentakawaguchi/Desktop/project/data/song.wav");
    AudioFormat format = AudioSystem.getAudioFileFormat(inputFile).getFormat();
    sampleRate = format.getSampleRate();
    double rate = p5.getController("HeartRate").getValue();
    println(rate);
    if (rate == 80) {
      rate = 0;
    } else if (rate < 80) {
      rate = (80 - rate) * -20;
    } else if (rate > 80) {
      rate = rate * 4;
    }
    println(rate);
    double factor = centToFactor(rate);
    audioPlayer = new AudioPlayer(format);
    rateTransposer = new RateTransposer(factor);
    wsola = new WaveformSimilarityBasedOverlapAdd(Parameters.musicDefaults(factor, sampleRate));
    dispatcher = AudioDispatcherFactory.fromFile(inputFile,wsola.getInputBufferSize(),wsola.getOverlap());
    wsola.setDispatcher(dispatcher);
    dispatcher.addAudioProcessor(wsola);
    dispatcher.addAudioProcessor(rateTransposer);
    dispatcher.addAudioProcessor(audioPlayer);


    Thread t = new Thread(dispatcher);
    t.start();

  } catch (UnsupportedAudioFileException e) {
      e.printStackTrace();
  } catch (IOException e) {
      e.printStackTrace();
  } catch (LineUnavailableException e) {
      e.printStackTrace();
  }

}

public void TimeStretch() {
  println("TimeStretch Pressed");

  try {
    if (dispatcher != null){
      dispatcher.stop();
    }
    
    File inputFile = new File("/Users/kentakawaguchi/Desktop/project/data/song.wav");
    AudioFormat format = AudioSystem.getAudioFileFormat(inputFile).getFormat();
    gain = new GainProcessor(1.0);

    audioPlayer = new AudioPlayer(format);
    
    double rate = p5.getController("HeartRate").getValue() / 75;
    
    wsola = new WaveformSimilarityBasedOverlapAdd(Parameters.slowdownDefaults(rate,format.getSampleRate()));
    
    dispatcher = AudioDispatcherFactory.fromFile(inputFile,wsola.getInputBufferSize(),wsola.getOverlap());
    wsola.setDispatcher(dispatcher);
    dispatcher.addAudioProcessor(wsola);
    dispatcher.addAudioProcessor(gain);
    dispatcher.addAudioProcessor(audioPlayer);


    Thread t = new Thread(dispatcher);
    t.start();

  } catch (UnsupportedAudioFileException e) {
      e.printStackTrace();
  } catch (IOException e) {
      e.printStackTrace();
  } catch (LineUnavailableException e) {
      e.printStackTrace();
  }
}