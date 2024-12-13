import processing.sound.*;
import java.util.ArrayList;
import java.util.HashMap;

ArrayList<PImage> images;
ArrayList<SoundFile> songs;
ArrayList<String> songNames;
HashMap<String, Integer> songPlayData; 

boolean isPlaying = false;
int imageSize = 100;
int margin = 40;
int textOffset = 35; // space reserved for text under images
SoundFile currentSong = null; // tracks the currently playing song
int[] currentBarHeights; // tracks current bar heights for animation

void setup() {
  size(700, 500);
  textSize(14);
  fill(255);

  images = new ArrayList<PImage>();
  songs = new ArrayList<SoundFile>();
  songNames = new ArrayList<String>();
  songPlayData = new HashMap<String, Integer>();
  currentBarHeights = new int[9];

  // Load images
  images.add(loadImage("2+2=5.jpg"));
  images.add(loadImage("976-evil.jpg"));
  images.add(loadImage("pearl_diver.jpeg"));
  images.add(loadImage("everlong.jpeg"));
  images.add(loadImage("scar_tissue.jpeg"));
  images.add(loadImage("the_less_i_know.jpeg"));
  images.add(loadImage("there_is_light.jpeg"));
  images.add(loadImage("optimistic.jpeg"));
  images.add(loadImage("call_it_fate.jpeg"));

  // Load songs
  songs.add(new SoundFile(this, "2+2=5.mp3"));
  songs.add(new SoundFile(this, "976-evil.mp3"));
  songs.add(new SoundFile(this, "pearl_diver.mp3"));
  songs.add(new SoundFile(this, "everlong.mp3"));
  songs.add(new SoundFile(this, "scar_tissue.mp3"));
  songs.add(new SoundFile(this, "the_less_i_know.mp3"));
  songs.add(new SoundFile(this, "there_is_light.mp3"));
  songs.add(new SoundFile(this, "optimistic.mp3"));
  songs.add(new SoundFile(this, "call_it_fate.mp3"));
  
  // Add song names
  songNames.add("2+2=5");
  songNames.add("976-EVIL");
  songNames.add("Pearl Diver");
  songNames.add("Everlong");
  songNames.add("Scar Tissue");
  songNames.add("The Less I Know The Better");
  songNames.add("There Is a Light That Never Goes Out");
  songNames.add("Optimistic");
  songNames.add("Call It Fate, Call It Karma");

  // Resize images
  for (PImage img : images) {
    img.resize(0, imageSize);
  }
  
  // Load ms_played data from the CSV
  loadCSVData("streaming_history.csv");
}

// Function to load and parse the CSV data
void loadCSVData(String filename) {
  Table table = loadTable(filename, "csv");

  // Take each row from the table and store data in songPlayData
  for (TableRow row : table.rows()) {
    String songName = row.getString(0); // get the song name (first column)
    int msPlayed = row.getInt(1);       // get the milliseconds played value (second column)

    // Add to HashMap
    songPlayData.put(songName, msPlayed);
  }
}

void drawLegend() {
  int legendX = width / 2 - 100;
  int legendY = height - 30;
  int squareSize = 15;

  // Draw red square
  fill(255, 100, 100);
  rect(legendX, legendY - squareSize, squareSize, squareSize);

  // Write text
  fill(255);
  text("milliseconds played last week", legendX + squareSize + 10, legendY);
}

void draw() {
  background(30);
  
  // Initialize the maxMsPlayed to 0
  int maxMsPlayed = 0;

  // Find the maximum ms_played value
  for (int msPlayed : songPlayData.values()) {
    if (msPlayed > maxMsPlayed) {
      maxMsPlayed = msPlayed;
    }
  }
  
  // Render images in a 3x3 grid
  int cols = 3;
  int x, y;
  boolean isHovering = false;

  for (int i = 0; i < images.size(); i++) {
    x = margin + (i % cols) * (width - 2 * margin) / cols + (width - 2 * margin) / cols / 2 - images.get(i).width / 2;
    y = margin + (i / cols) * (height - 2 * margin) / cols + (height - 2 * margin) / cols / 2 - images.get(i).height / 2 - textOffset;
    image(images.get(i), x, y);

    // Display text under each image
    fill(255);
    String songName = songNames.get(i);
    text(songName, x + images.get(i).width / 2 - textWidth(songName) / 2, y + imageSize + 15);
    
    // Calculate target bar height
    int msPlayed = songPlayData.getOrDefault(songName, 0);  // check if the song is displayed
    int maxBarHeight = imageSize;
    int targetBarHeight = (int) map(msPlayed, 0, maxMsPlayed, 10, maxBarHeight); // bar height proportional to ms_played
    
    // Check if the mouse is hovering over this image
    if (mouseX > x && mouseX < x + images.get(i).width && mouseY > y && mouseY < y + images.get(i).height) {
      isHovering = true;
      // Increment bar height towards target
      if (currentBarHeights[i] < targetBarHeight) {
        currentBarHeights[i] += 5; // grow by 5 pixels per frame
      }
      // Play the corresponding song
      if (currentSong != songs.get(i)) {
        if (currentSong != null) {
          currentSong.stop(); // stop the previous song
        }
        currentSong = songs.get(i);
        currentSong.loop(); // play the new song
      }
    } else {
      // Reset bar height if not hovering
      if (currentBarHeights[i] > 0) {
        currentBarHeights[i] -= 5; // shrink by 5 pixels per frame
      }
    }

    // Draw the animated bar
    fill(255, 100, 100);
    rect(x + images.get(i).width + 10, y + imageSize - currentBarHeights[i], 20, currentBarHeights[i]);
  }

  // Stop any song if no image is hovered
  if (!isHovering && currentSong != null) {
    currentSong.stop();
    currentSong = null;
  }
  
  // Draw legend method
  drawLegend();
}
