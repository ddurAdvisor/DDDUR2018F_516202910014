String filename = "SJTU National Day Holidayn Weather Viewdata.csv";
String[] allData;
ArrayList<Election> allElections = new ArrayList<Election>();
ArrayList<Sort> allCandidates = new ArrayList<Sort>();
int graphTop;
int graphBottom;
int graphHeight;
float margin;
int boxHeight;
float secWidth;
int backgroundCol = 180;
PFont typeFont;
PFont dayFont;
int dayFontLarge = 50;
int dayFontSmall = 16;
int typeFontSize = 28;
int renderday = 1001;
String renderCategory = "time0000";
boolean buttonHover, displayMenu;
PFont p;

void setup() {
  size(1000, 800);
  smooth();
  typeFont = loadFont("Arial-Black-48.vlw");
  dayFont = loadFont("AppleGothic-48.vlw");
  graphTop = height - 120;
  graphBottom = height - 50;
  graphHeight = graphBottom - graphTop;
  margin = .04 * width;
  boxHeight = 80;
  parseData();
p = createFont("simfang.ttf", 50);
  textFont(p);
}

void draw() {
  background(backgroundCol);
PImage img = loadImage("sjtu.png");
      image(img,0,60,img.width*0.7, img.height*0.6);
  checkMouse();
  for (Election e : allElections) {
    if (e.electionDay == renderday) {
      e.render(renderCategory);
    }
  }
  if(displayMenu) {
    displayMenu(); 
  }  
  drawGUI();
  drawLineGraph();
}

void drawLineGraph() {
  float[] democrats = new float[allElections.size()];
  float[] republicans = new float[allElections.size()];
  int demCounter = 0;
  int repCounter = 0;  
  for(int i=allElections.size()-1; i>=0; i--) {
    Election thisElection = allElections.get(i);
    for(int j=0; j<thisElection.totalSorts; j++) {
      if(j==0) {
        Sort thisCandidate = thisElection.sorts.get(j);
        for(Category cat : thisCandidate.categories) {
          if(cat.time.equals(renderCategory)) {
            democrats[demCounter] = cat.value;
            demCounter++;
          } 
        }
      } else if(j==1) {
        Sort thisCandidate = thisElection.sorts.get(j);
        for(Category cat : thisCandidate.categories) {
          if(cat.time.equals(renderCategory)) {
            republicans[repCounter] = cat.value;
            repCounter++;
          } 
        }
      }
    } 
  }  
  ArrayList<Election> others = new ArrayList<Election>();
  for(Election e : allElections) {
     if(e.totalSorts > 2) {
       others.add(e); 
     }
  }
  for(int i=0; i<allElections.size(); i++) {
    Election thisElection = allElections.get(i);
    float maxValue = max(democrats[i], republicans[i]);
    maxValue = map(maxValue, 0, 100, 0, graphHeight);
    stroke(255);
    strokeWeight(1);
    line(secWidth*thisElection.index, graphBottom, secWidth*thisElection.index, graphBottom - maxValue);
    thisElection.renderFlag(i);  
}
  strokeWeight(3);
  noFill(); 
  beginShape(); 
  stroke(#0D3574);
  for(int i=0; i<democrats.length; i++) {
    float thisValue = map(democrats[i], 0, 100, 0, graphHeight);
    vertex(secWidth*(i+1), graphBottom - thisValue);
    ellipse(secWidth*(i+1), graphBottom - thisValue, 5, 5);
  }
  endShape();
 beginShape(); 
  stroke(#FF3434);
  for(int i=0; i<republicans.length; i++) {
    float thisValue = map(republicans[i], 0, 100, 0, graphHeight);
    vertex(secWidth*(i+1), graphBottom - thisValue);
    ellipse(secWidth*(i+1), graphBottom - thisValue, 5, 5);
  }
  endShape(); 
  strokeWeight(5);
  stroke(25);
  line(secWidth, graphBottom, width - secWidth, graphBottom);  
  stroke(#F2F0F0);
  strokeWeight(2);
  fill(#F2F0F0);
  for(int i=0; i<others.size(); i++) {
    Election thisElection = others.get(i);
    Sort thisCandidate = thisElection.sorts.get(2);
    for(Category cat : thisCandidate.categories) {
      if(cat.time.equals(renderCategory)) {
        float thisValue = map(cat.value, 0, 100, 0, graphHeight);
        ellipse(width - secWidth*thisElection.index - 8, graphBottom - thisValue, 5, 5); 
      }
    } 
  }
 text("SJTU National Day Holidayn Weather Viewdata",350, 30); 
}

void drawGUI() {
  textFont(dayFont, dayFontLarge);
  textAlign(LEFT);
  if(buttonHover) {
   stroke(0, 100); 
  } else {
   noStroke();
  }
  fill(255);
  rect(0, margin, textWidth(renderCategory)*1.25 + margin, boxHeight);
  fill(25);
  text("\"" + renderCategory + "\"", margin/2, margin + boxHeight - dayFontLarge/2);
  rect(0, margin+ boxHeight, margin + textWidth("00000"), boxHeight);
  fill(255);
  text(renderday, margin, margin + boxHeight*2 - dayFontLarge/2);
  secWidth = width/(allElections.size()+1);
  fill(#0D3574);
  rect(secWidth, height - 230, 20, 20);
  fill(#FF3434);
  rect(secWidth, height - 200, 20, 20);
  fill(#F2F0F0);
  rect(secWidth, height - 170, 20, 20);
  fill(255);
  textSize(dayFontSmall);
  text("Wind speed", secWidth + 30, height - 214);
  text("Temperature", secWidth + 30, height - 183);
  text("Wind direction", secWidth + 30, height - 153);
}

void parseData() {
  allData = loadStrings(filename);
  int[] days = int(allData[0].split(","));
  String[] names = allData[1].split(",");
  for (int column=1; column<days.length; column++) {
    int electionYear = days[column];
    Election thisElection;
    Sort thisCandidate;
    if (electionYear == days[column-1]) {
      thisElection = allElections.get(allElections.size()-1);
      thisCandidate = new Sort(names[column], electionYear, thisElection.totalSorts +1);
      thisElection.totalSorts += 1;
    } 

    else {
      thisElection = new Election(electionYear);
      thisCandidate = new Sort(names[column], electionYear, 1);
      allElections.add(thisElection);
      thisElection.index = allElections.size();
    }
    for (int i=2; i<allData.length; i++) {
      String[] thisRow = allData[i].split(",");
      String title = thisRow[0];
      int value = int(thisRow[column]);
      Category thisCategory = new Category(title, value);
      thisCandidate.categories.add(thisCategory);
    }
  thisElection.sorts.add(thisCandidate);
   allCandidates.add(thisCandidate);
  }
}

void checkMouse() {
  if(mouseY > margin && mouseY< margin+boxHeight && mouseX < renderCategory.length()*55) {
    buttonHover = true; 
  } else {
    buttonHover = false; 
  }
}  

void mouseClicked() {
  if(buttonHover) {
    displayMenu = !displayMenu;
  } 
  for(int i=1; i<allElections.size()+1; i++) {
    if(mouseX > secWidth*i - secWidth/2 && mouseX < secWidth*i + secWidth/2 &&
    mouseY > graphTop && !displayMenu) {
      Election thisElection = allElections.get(allElections.size() - i);
      renderday = thisElection.electionDay; 
    }
  }
}
void displayMenu() {
  textFont(dayFont);
  textAlign(LEFT);
  stroke(255, 20); 
  float heightTracker = margin + boxHeight;
  int bHeight = 20;
  int boxWidth = 220;
  int colCounter = 0;  
  for(int i=2; i<allData.length; i++) {
    String[] thisRow = allData[i].split(",");
    textSize(dayFontLarge);
    float boxX = margin + textWidth("00000") + (colCounter * boxWidth);
    textSize(dayFontSmall);
    if(mouseX > boxX && mouseX < boxX + boxWidth && mouseY > heightTracker 
    && mouseY < heightTracker + bHeight) {
     fill(255);
     rect(boxX, heightTracker, boxWidth, bHeight);
     fill(25);
     text(thisRow[0], boxX+5, heightTracker + 16);
     if(mousePressed) {
       renderCategory = thisRow[0];
       displayMenu = false; 
     }
    } else { 
      fill(25);
      rect(boxX, heightTracker, boxWidth, bHeight);
      fill(255);
      text(thisRow[0], boxX + 5, heightTracker + 16);
    }
    heightTracker += bHeight;
   if(heightTracker > height - 160) {
      heightTracker = margin + boxHeight;
      colCounter++; 
    }
  }
}

class Category {
  String time;
  int value;
 Category(String _time, int _value) {
    time = _time;
    value = _value;
  } 
}

class Election {
 int electionDay;
  int totalSorts;
  int index;
  ArrayList<Sort> sorts = new ArrayList<Sort>(); 
 Election(int _day) {
    electionDay = _day;
    totalSorts = 1;
  }
 void render(String _category) {
    String searchTitle = _category;
    color[] colors = {
      color(#FF3434), color(#0D3574), color(#F2F0F0)
    };
    noStroke();
   float x = width/2 + margin;
    float y = height/2 - 50;
    float renderRadius = 600;
    float hole = 0.55*renderRadius;
    float start = radians(90);
    for (int i=0; i<totalSorts; i++) {
      Sort thisCandidate = sorts.get(i);
      for (Category cat : thisCandidate.categories) {
        if (cat.time.equals(searchTitle)) {
          float renderValue = start + radians((cat.value/100.0) * 360);
          fill(colors[i]);
          arc(x, y, renderRadius, renderRadius, start, renderValue);
          start = renderValue;
        }
      }
    }
    stroke(backgroundCol);
    strokeWeight(2);
    for(int angle=0; angle<360; angle+=2) {
      float outerX = x + ((renderRadius/2)*cos(radians(angle)));
      float outerY = y + ((renderRadius/2)*sin(radians(angle)));
      line(x, y, outerX, outerY);
    }
    fill(backgroundCol);
    noStroke();
    ellipse(x, y, hole, hole);
    for (Sort c : sorts) {
      int startY;
      float spacing;
      if(sorts.size() > 2) {
        startY = 180;
        spacing = 80*c.index; 
      }
      else {
        startY = 235;
       spacing = 80*c.index; 
      }      
      textFont(typeFont, typeFontSize);
      fill(colors[c.index-1]);
      textAlign(CENTER);
      strokeWeight(1);
      text(c.type, x, startY + spacing);
      for(Category cat : c.categories) {
        if(cat.time.equals(searchTitle)) {
          text(int(cat.value) , x, startY + 30 + spacing);
        } 
      }
    }
 stroke(25);
 strokeWeight(3);
  line(width - (secWidth*index) - 8, height-10, width - (secWidth*index) - 8, graphBottom);
  fill(25);
  stroke(25);
  rect(width - (secWidth*index) - 8, height-30, secWidth, 20);
  textFont(dayFont, dayFontSmall);
  fill(255);
  textAlign(LEFT);
  text(electionDay, width - (secWidth*index), height -14);
}
 void renderFlag(int _i) {
    _i = _i + 1;
    float sectionWidth = secWidth*_i;
    if(mouseY > graphTop && mouseX > sectionWidth - secWidth/2 &&
    mouseX < sectionWidth + secWidth/2) {
     strokeWeight(3);
     line(sectionWidth, graphBottom, sectionWidth, graphTop);
     fill(255);
     rect(sectionWidth, graphTop - 20, secWidth, 20);
     textFont(dayFont, dayFontSmall);
     fill(25);
     text(1007 - (_i-1)*1, sectionWidth + 6, graphTop - 4);
    }
  }
}

class Sort {
  String type;
  int elecDay;
  int index;
  ArrayList<Category> categories = new ArrayList<Category>();
  Sort(String _type, int _day, int _index) {
    type = _type;
    elecDay = _day;
    index = _index; 
  }
}
