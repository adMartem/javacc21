/* Generated by: ${generated_by}. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

[#set classname = filename?substring(0, filename?length-5)]
[#set options = grammar.options]

import java.io.*;

public class ${classname} {

    private int tokenBegin;
    private int bufpos = -1;
    private int backupAmount;
    private Reader nestedReader;
    private StringBuilder pushBackBuffer = new StringBuilder();
    private int column = 0, line = -1, tabSize =8;
    private boolean prevCharIsCR, prevCharIsLF;
    private char lookaheadBuffer[] = new char[8192]; // Maybe this should be adjustable but 8K should be fine. Maybe revisit...
    private int lookaheadIndex, charsReadLast;
        

    /** The buffersize parameter is only there for backward compatibility. It is currently ignored. */
    public ${classname}(Reader reader, int startline, int startcolumn, int buffersize) {
        this(reader, startline, startcolumn);
     }

    public ${classname}(Reader reader, int startline, int startcolumn) {
        this.nestedReader = reader;
        line = startline;
        column = startcolumn - 1;
    }

    public ${classname}(Reader reader) {
        this(reader, 1, 1);
    }


    /**
     * sets the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public void setTabSize(int tabSize) {this.tabSize = tabSize;}
    
    /**
     * returns the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public int getTabSize() {return tabSize;}
    

   
     public void backup(int amount) {
        backupAmount += amount;
        bufpos -= amount;
        if (bufpos  < 0) {
                throw new RuntimeException("Should never get here, I don't think!");
        } 
    }


    public String getImage() {
          StringBuilder buf = new StringBuilder();
          for (int i =tokenBegin; i<= bufpos; i++) {
              buf.append(getCharAt(i));
          }
          return buf.toString();
    }
    
    String getSuffix(final int len) {
         StringBuilder buf = new StringBuilder();
         int startPos = bufpos - len +1;
         for (int i=0; i<len; i++) {
             buf.append(getCharAt(startPos +i));
        }
        return buf.toString();
    } 

     int readChar() {
        ++bufpos;
        if (backupAmount > 0) {
           --backupAmount;
           return getCharAt(bufpos);
        }
         int ch = read();
         if (ch ==-1) {
           if (bufpos >0) --bufpos;
         }
        return ch;
    }

  
    int beginToken() {
         if (backupAmount > 0) {
              --backupAmount;
            ++bufpos;
            tokenBegin = bufpos;
            return getCharAt(bufpos);
        }
        tokenBegin = 0;
        bufpos = -1;
        return readChar();
    }
    
    
   
    int getBeginColumn() {
        return getColumn(tokenBegin);
    }
    
    int getBeginLine() {
        return getLine(tokenBegin);
    }
   
    int getEndColumn() {
        return getColumn(bufpos);
    }
    
    int getEndLine() {
        return getLine(bufpos);
    }
       
   
    private int nextChar()  {

        if (lookaheadIndex<charsReadLast) {
            return lookaheadBuffer[lookaheadIndex++];
        }
        if (charsReadLast >0 && charsReadLast < 8192) {
            return -1;
        }
        try {
            charsReadLast = nestedReader.read(lookaheadBuffer, 0, 8192);
            if (charsReadLast <= 0) {
                 return -1;
            }
        } catch (IOException ioe) {
             return -1; // Maybe handle this. REVISIT
        }
        lookaheadIndex = 0;
        return lookaheadBuffer[lookaheadIndex++];
    }

    private int read()  {
         int ch;
         int pushBack = pushBackBuffer.length();
         if (pushBack >0) {
             ch = pushBackBuffer.charAt(pushBack -1);
             pushBackBuffer.setLength(pushBack -1);
             updateLineColumn(ch);
             return ch;
         }
         ch = nextChar();
         if (ch <0) {
             return ch;
         }
             
[#if grammar.options.javaUnicodeEscape]             
         if (ch == '\\') {
             ch = handleBackSlash();
         } else {
             lastCharWasUnicodeEscape = false;
         }
[/#if]
         updateLineColumn(ch);
         return ch;
    }
        
    private void pushBack(int ch) {
       pushBackBuffer.append((char) ch);
    }
    
    private void updateLineColumn(int c) {
        column++;
        if (prevCharIsLF || (prevCharIsCR && c!='\n')) {
            ++line;
            column = 1;
        }
        prevCharIsCR = (c=='\r');
        prevCharIsLF = (c=='\n');
        setLocationInfo(bufpos, c, line, column);
    }

        
[#if grammar.options.javaUnicodeEscape]
    private StringBuilder hexEscapeBuffer = new StringBuilder();
    private boolean lastCharWasUnicodeEscape;
    
    private int handleBackSlash() {
           int nextChar = nextChar();
           if (nextChar != 'u') {
               pushBack(nextChar);
               lastCharWasUnicodeEscape = false;
               return '\\';
           }
           hexEscapeBuffer = new StringBuilder("\\u");
           while (nextChar == 'u') {
              nextChar = nextChar();
              hexEscapeBuffer.append((char) nextChar);
           }
          // NB: There must be 4 chars after the u and 
          // they must be valid hex chars! REVISIT.
           for (int i =0;i<3;i++) {
               hexEscapeBuffer.append((char) nextChar());
           }
           String hexChars = hexEscapeBuffer.substring(hexEscapeBuffer.length() -4);
           lastCharWasUnicodeEscape = true;
           return Integer.parseInt(hexChars, 16);
    }
[/#if]

     private int[] locationInfoBuffer = new int[3072];
   
     private int getLine(int pos) {
         return locationInfoBuffer[pos*3+1];
     }
     
     private int getColumn(int pos) {
         return locationInfoBuffer[pos*3+2];
     }
     
     private char getCharAt(int pos) {
         return (char) locationInfoBuffer[pos*3];
     }
     
     private void setLocationInfo(int pos, int ch, int line, int column) {
          pos *=3;
          if (pos >= locationInfoBuffer.length) {
              expandBuff();
          }
          locationInfoBuffer[pos++] = ch;
          locationInfoBuffer[pos++] = line;
          locationInfoBuffer[pos++] = column;
    }
    
     private void expandBuff() {
           int[] newBuf = new int[locationInfoBuffer.length*2];
           System.arraycopy(locationInfoBuffer, 0, newBuf, 0,  locationInfoBuffer.length);
           locationInfoBuffer = newBuf;
     }
}

