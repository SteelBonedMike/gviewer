import java.io.File;

int tileWidth = 128;
int chunkWidth = tileWidth + 88;

PImage orig;
PImage crop;

PrintWriter luaOutput;
PrintWriter hOutput;

String fname;

void setup() {
    size(727, 600);
    luaOutput = createWriter("assets.lua");
    hOutput = createWriter("dims.h");
  selectInput("Select an image", "slice");
}



void slice(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    fname = selection.getName();
    println("User selected " + fname);
    orig = loadImage(fname);
    
  }
}

void draw() {
  if (orig == null) {
  } 

  else {
    
    noLoop();

    int cols = orig.width / chunkWidth;
    int rows = orig.height / chunkWidth;

    int idx;
    int idy;

    if ((orig.width - cols * chunkWidth) > (orig.height - rows*chunkWidth)) {
      orig.resize(0, rows*chunkWidth);
    }
    else {
      orig.resize(cols*chunkWidth, 0);
    }

    for (int r = 1; r <= rows; r = r + 1) {
      for (int c = 1; c <= cols; c = c + 1) {
        idx = (c-1) * chunkWidth;
        idy = (r-1) * chunkWidth;
        crop = orig.get(idx, idy, tileWidth, tileWidth);
        image(crop, idx, idy);
        crop.save("chunks/"+fname.substring(0,fname.indexOf("."))+"r"+r+"c"+c+".png");
      }
    }
   
   
   luaOutput.println("-- Metadata");
   luaOutput.println("IconAssets = group{quality=9.95}");
   luaOutput.println("Icon = image{\"icon.png\"}");
   luaOutput.println(" ");
   luaOutput.println("function frames(fmt, count1, count2)");
   luaOutput.println("  t = {}");
   luaOutput.println("  for i = 1, count1 do");
   luaOutput.println("    for j = 1, count2 do");
   luaOutput.println("      t[1+#t] = string.format(fmt, i, j)");
   luaOutput.println("    end");
   luaOutput.println("  end");
   luaOutput.println("  return t");
   luaOutput.println("end");
   luaOutput.println(" ");
   luaOutput.println("-- Animation: \"giga\"");
   luaOutput.println("gigaGroup = group{quality=6.3}");
   luaOutput.println("giga = image{ frames(\"chunks/"+fname.substring(0,fname.indexOf("."))+"r%dc%d.png\", "+rows+", "+cols+") }");
   luaOutput.flush();
   luaOutput.close();
   
   hOutput.println("#define NUM_ROWS "+rows);
   hOutput.println("#define NUM_COLS "+cols);
   hOutput.flush();
   hOutput.close();
    
  }
}
