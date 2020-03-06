/* Generated by: ${generated_by}. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

[#set classname = filename?substring(0, filename?length-5)]
[#set options = grammar.options]

import java.io.*;
import java.util.ArrayList;


public class ${classname} {


    private class LocationInfo {
         int ch=-1, line, column;
    }

   private ArrayList<LocationInfo> locationInfoBuffer = new ArrayList<>();
   
   private LocationInfo getLocationInfo(int pos) {
   
       while (pos >= locationInfoBuffer.size()) {
            locationInfoBuffer.add(null);
       }
       
       LocationInfo linfo = locationInfoBuffer.get(pos);
       
       if (linfo == null) {
           linfo = new LocationInfo();
           locationInfoBuffer.set(pos, linfo); 
       }
       
       return linfo;
   
   }
    private void maybeResizeBuffer() {
         if (tokenBegin > 2048) {
         // If we are starting a new token this far into the buffer, we throw away 1024 initial bytes
         // Totally ad hoc, maybe revisit the numbers, though it may not matter very much.
              ArrayList<LocationInfo> newBuffer = new ArrayList<>(locationInfoBuffer.size());
              for (int i=1024; i<locationInfoBuffer.size(); i++) {
                  newBuffer.add(locationInfoBuffer.get(i));
              }
              locationInfoBuffer = newBuffer;
              bufpos -=1024;
              tokenBegin -=1024;
         }
    }

    private final int bufsize = 4096;
    private int tokenBegin;
    private int bufpos = -1;
    private int column = 0;
    private int line = 1;
    private boolean prevCharIsCR, prevCharIsLF;
    private WrappedReader reader;
    
    [#if grammar.options.javaUnicodeEscape]
    private int maxNextCharInd;
    [/#if]
    private int backupAmount, tabSize=8;
    
    
     int getBeginColumn() {
        return getLocationInfo(tokenBegin).column;
    }
    
        int getBeginLine() {
        return getLocationInfo(tokenBegin).line;
    }
   
        int getEndColumn() {
        return getLocationInfo(bufpos).column;
    }
    
        int getEndLine() {
        return getLocationInfo(bufpos).line;
    }
    
   
     public void backup(int amount) {
        backupAmount += amount;
        bufpos -= amount;
        if (bufpos  < 0) {
//              bufpos = 0;
            bufpos += bufsize;
        }
    }

    
        
    /**
     * sets the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public void setTabSize(int i) {this.tabSize = i;}
    
    /**
     * returns the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public int getTabSize() {return tabSize;}
    
    private void updateLineColumn(int c) {
        column++;
        if (prevCharIsLF) {
            prevCharIsLF = false;
            ++line;
            column = 1;
        }
        else if (prevCharIsCR) {
            prevCharIsCR = false;
            if (c == '\n') {
                prevCharIsLF = true;
            }
            else {
                ++line;
                column = 1;
            }
        }
        switch(c) {
            case '\r' : 
                prevCharIsCR = true;
                break;
            case '\n' : 
                prevCharIsLF = true;
                break;
            case '\t' : 
                column--;
                column += (tabSize - (column % tabSize));
                break;
            default : break;
        }
        getLocationInfo(bufpos).line = line;
        getLocationInfo(bufpos).column = column;
    }
    
    
     public int readChar() throws IOException {
        if (backupAmount > 0) {
           --backupAmount;
           ++bufpos;
           if (bufpos == bufsize) { //REVISIT!
               bufpos = 0;
           }
           return getLocationInfo(bufpos).ch;         
        }
        ++bufpos;
[#if !options.javaUnicodeEscape]
         int ch = reader.read();
         if (ch ==-1) {
           --bufpos;
          backup(0);
          if (tokenBegin <0) {
              tokenBegin = bufpos;
          }
           throw new IOException();
         }
       getLocationInfo(bufpos).ch = ch;
        int c = getLocationInfo(bufpos).ch;
        updateLineColumn(c);
        return c;
    }
        
[#else]
        int c = (int) readByte();
          getLocationInfo(bufpos).ch = c;
[#if false]          
          if (c == '\\') {

            updateLineColumn(c);
            int backSlashCnt = 1;

            for (;;) // Read all the backslashes
            {
                ++bufpos;
                try {
                    c = readByte();
                    getLocationInfo(bufpos).ch = c;
                    if (c != '\\') { 
                        updateLineColumn(c);
                        // found a non-backslash char.
                        if ((c == 'u') && ((backSlashCnt & 1) == 1)) {
                            if (--bufpos < 0)
                                bufpos = bufsize - 1;

                            break;
                        }

                        backup(backSlashCnt);
                        return '\\';
                    }
                } catch (IOException e) {
                    if (backSlashCnt > 1)
                        backup(backSlashCnt - 1);
                    return '\\';
                }
                updateLineColumn(c);
                backSlashCnt++;
            }

            // Here, we have seen an odd number of backslash's followed by a 'u'
            try {
                while ((c = readByte()) == 'u')
                    ++column;
                LocationInfo linfo = getLocationInfo(bufpos);
                c = (hexval(c) << 12
                        | hexval(readByte()) << 8 | hexval(readByte()) << 4 | hexval(readByte()));
                getLocationInfo(bufpos).ch = c;

                column += 4;
            } catch (IOException e) {
                throw new Error("Invalid escape character at line " + line
                        + " column " + column + ".");
            }

            if (backSlashCnt == 1) {
                return c;
            }
            else {
                backup(backSlashCnt - 1);
                return '\\';
            }
        }
[/#if]        
        updateLineColumn(c);
        return c;
    }
[/#if]        
    
   

    /** The buffersize parameter is only there for backward compatibility. It is currently ignored. */
    public ${classname}(Reader reader, int startline, int startcolumn, int buffersize) {
        this.reader = new WrappedReader(reader);
        line = startline;
        column = startcolumn - 1;
        
[#if options.javaUnicodeEscape]
        nextCharBuf = new char[4096];
[/#if]
     }

    public ${classname}(Reader reader, int startline, int startcolumn) {
        this(reader, startline, startcolumn, 4096);
    }

    public ${classname}(Reader reader) {
        this(reader, 1, 1, 4096);
    }
    
    /** Get token literal value. */
    public String getImage() {
        if (bufpos >= tokenBegin) { 
              StringBuilder buf = new StringBuilder();
              for (int i =tokenBegin; i<= bufpos; i++) {
                  buf.append((char) getLocationInfo(i).ch);
              }
              return buf.toString();
        }
        else { 
             StringBuilder buf = new StringBuilder();
             for (int i=tokenBegin; i<bufsize; i++) {
                  buf.append((char) getLocationInfo(i).ch);
             }
             for (int i=0; i<=bufpos; i++) {
                  buf.append((char) getLocationInfo(i).ch);
             }
             return buf.toString();
        }
    }
    
    public char[] getSuffix(final int len) {
        char[] ret = new char[len];
        if ((bufpos + 1) >= len) { 
             int startPos = bufpos - len +1;
             for (int i=0; i<len; i++) {
                 ret[i] = (char) getLocationInfo(startPos+i).ch;
             }
        }
        else {
            int startPos = bufsize - (len-bufsize-1);
            int lengthToCopy = len - bufpos -1;
            for (int i=0; i<lengthToCopy; i++) {
                ret[i] = (char) getLocationInfo(startPos+i).ch;
            }
            lengthToCopy = len - bufpos -1;
            int destPos = len-bufpos-1;
            for (int i=0; i<lengthToCopy; i++) {
                ret[destPos+i] = (char) getLocationInfo(i).ch;
            }
            
        }
        return ret;
    } 

  
[#if grammar.options.javaUnicodeEscape]

    static boolean isHexVal(int c) {
        return (c>= '0' && c<='9') || (c>='a' && c<='f') || (c>='A'&&c<='F');
    }
  


  static int hexval(int c) {
    if (c>= '0' && c<='9') {
        return c-'0';
    }
    if (c>='a' && c<='f') {
       return 10+c-'a';
    }
    if (c>='A' && c<='F') {
        return 10+c-'A';
    }
    throw new RuntimeException("Cannot parse escaped unicode char");// REVISIT, currently unhandled
  }

 
    private int readByte() throws IOException {
        ++nextCharInd;
        if (nextCharInd >= maxNextCharInd)
            fillBuff();

        return (int) nextCharBuf[nextCharInd];
    }

    [#--  JavaCharStream case --]
    private void fillBuff() throws IOException {
        if (maxNextCharInd == 4096)
            maxNextCharInd = nextCharInd = 0;

        try {
            int charsRead =   reader.read(nextCharBuf, maxNextCharInd, 4096 - maxNextCharInd);
            if (charsRead == -1) {
                throw new IOException();
            } 
            maxNextCharInd += charsRead;
            return;
        } catch (IOException e) {
            if (bufpos != 0) {
                --bufpos;
                backup(0);
            } else {
                getLocationInfo(bufpos).line = line;
                getLocationInfo(bufpos).column = column;
            }
            throw e;
        }
    }
  
    public int beginToken() { 
            if (backupAmount > 0) {
            --backupAmount;
           if (++bufpos == bufsize)
                bufpos = 0;
           tokenBegin = bufpos;
            return getLocationInfo(bufpos).ch;
        }
        tokenBegin = 0;
        bufpos = -1;
        try {        
        	return readChar();
        } catch (IOException ioe) {
            return -1;
        }
    }
    
    private char[] nextCharBuf;
    private int nextCharInd = -1;
[#else]
    [#--  SimpleCharStream case --]
     public int beginToken() {
        tokenBegin = -1;
        maybeResizeBuffer();
        try {
	        int c = readChar();
	        tokenBegin = bufpos;
	        return c;
        } catch (IOException ioe) {
            return -1;
        }
    }
[/#if]

    private class WrappedReader extends Reader {
    
        StringBuilder buf;
        Reader nestedReader;
        StringBuilder pushBackBuffer = new StringBuilder();
        
        
        WrappedReader(Reader nestedReader) {
            this.nestedReader = nestedReader;
         }
         
        private int nextChar() throws IOException {
            return nestedReader.read();
        }

        
        
        public void close() throws IOException {
            nestedReader.close();
        }
        
        public int read() throws IOException {
        
             int ch;
             int pushBack = pushBackBuffer.length();
             if (pushBack >0) {
                 ch = pushBackBuffer.charAt(pushBack -1);
                 pushBackBuffer.setLength(pushBack -1);
                 return ch;
             }
             ch = nextChar();
[#if grammar.options.javaUnicodeEscape]             
             if (ch == '\\') {
                 ch = handleBackSlash();
             } else {
                 lastCharWasUnicodeEscape = true;
             }
[/#if]             
             return ch;
        }
        
        public int read (char[] cbuf, int off, int len) throws IOException {
//            return nestedReader.read(cbuf, off, len);
              int i;
              for (i=0; i<len; i++) {
                  int ch = read();
                  if (ch == -1) {
                       if (i==0) {
                           throw new IOException();
                       }
                       return i;
                  }
                  cbuf[off+i] = (char) ch;
              }
              return len;
        }
        
        void pushBack(int ch) {
           pushBackBuffer.append((char) ch);
        }
              
        
[#if grammar.options.javaUnicodeEscape]

        StringBuilder hexEscapeBuffer = new StringBuilder();
        boolean lastCharWasUnicodeEscape;
        
        private int handleBackSlash() throws IOException {
//              System.out.println("KILROY WAS HERE");
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
//               System.out.println("KILROY: " + hexChars);
               lastCharWasUnicodeEscape = true;
               return Integer.parseInt(hexChars, 16);
        }
[/#if]        
        
    }


}

