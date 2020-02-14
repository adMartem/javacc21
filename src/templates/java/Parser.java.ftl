[#ftl strict_vars=true]
[#--
/* Copyright (c) 2008-2019 Jonathan Revusky, revusky@javacc.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notices,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary formnt must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name Jonathan Revusky, Sun Microsystems, Inc.
 *       nor the names of any contributors may be used to endorse 
 *       or promote products derived from this software without specific prior written 
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */
 --]
/* Generated by: ${generated_by}. ${filename} */

[#import "javacode.ftl" as javacode]
[#var parserData=grammar.parserData]
[#var hasPhase2=parserData.phase2Lookaheads?size != 0]
[#var tokenCount=grammar.lexerData.tokenCount]
[#var includeTreeCode=true]

[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

[#if grammar.nodePackage?has_content && grammar.parserPackage! != grammar.nodePackage]
import ${grammar.nodePackage}.*;  
[/#if]

@SuppressWarnings("unused")
public class ${grammar.parserClassName} implements ${grammar.constantsClassName} {

[#if grammar.options.treeBuildingEnabled]
   [#embed "javatreecode.ftl"]
[/#if]

[#if grammar.options.userDefinedLexer]
  private String inputSource = "input";
  /** User defined Lexer. */
  public Lexer token_source;
[#else]
  /** Generated Lexer. */
  public ${grammar.lexerClassName} token_source;
  [#if !grammar.options.userCharStream]
      [#if grammar.options.javaUnicodeEscape]
  JavaCharStream inputStream;
      [#else]
  SimpleCharStream inputStream;
      [/#if]
  [/#if]
  
  public void setInputSource(String inputSource) {
      token_source.setInputSource(inputSource);
  }
  
[/#if]

  String getInputSource() {
      return token_source.getInputSource();
  }

  Token current_token;
[#if hasPhase2] 
  private Token jj_scanpos, jj_lastpos;
  private int jj_la;
  /** Whether we are looking ahead. */
  private boolean jj_lookingAhead = false;
  private boolean jj_semLA;
[/#if]

[#if grammar.options.errorReporting]
  private int jj_gen;
  final private int[] jj_la1 = new int[${parserData.tokenMaskValues?size}];
 [#var tokenMaskSize=(tokenCount-1)/32]
 [#list 0..tokenMaskSize as i] 
  static private int[] jj_la1_${i};
 [/#list]
  static {
 [#list 0..tokenMaskSize as i]
      jj_la1_init_${i}();
 [/#list]
  }
  
 [#list 0..tokenMaskSize as i] 
   private static void jj_la1_init_${i}() {
      jj_la1_${i} = new int[] {
        [#list parserData.tokenMaskValues as tokenMask]
             ${utils.toHexString(tokenMask[i])} [#if tokenMask_has_next],[/#if]
        [/#list]
      };
   }
 [/#list]
[/#if]

[#if hasPhase2&&grammar.options.errorReporting]
  final private JJCalls[] jj_2_rtns = new JJCalls[${parserData.phase2Lookaheads?size}];
  private boolean rescan = false;
  private int jj_gc = 0;
[/#if]

[#if !grammar.options.userDefinedLexer]
   [#if grammar.options.userCharStream]
  /** Constructor with user supplied CharStream. */
  public ${grammar.parserClassName}(CharStream stream) {
       [#if grammar.options.lexerUsesParser]
    token_source = new ${grammar.lexerClassName}(this, stream);
       [#else]
    token_source = new ${grammar.lexerClassName}(stream);
       [/#if]
    current_token = new Token();
       [#if grammar.options.errorReporting]
    for (int i = 0; i < ${parserData.tokenMaskValues?size}; i++) jj_la1[i] = -1;
          [#if hasPhase2]
    for (int i = 0; i < jj_2_rtns.length; i++) jj_2_rtns[i] = new JJCalls();
          [/#if]
       [/#if]
  }

  [#else]

  public ${grammar.parserClassName}(java.io.InputStream stream) {
      this(new java.io.InputStreamReader(stream));
  }

  public ${grammar.parserClassName}(java.io.Reader stream) {
     [#if grammar.options.javaUnicodeEscape]
    inputStream = new JavaCharStream(stream, 1, 1);
     [#else]
    inputStream = new SimpleCharStream(stream, 1, 1);
     [/#if]
    [#if grammar.options.lexerUsesParser]
    token_source = new ${grammar.lexerClassName}(this, inputStream);
    [#else]
    token_source = new ${grammar.lexerClassName}(inputStream);
    [/#if]
    current_token = new Token();
    [#if grammar.options.errorReporting]
    for (int i = 0; i < ${parserData.tokenMaskValues?size}; i++) jj_la1[i] = -1;
        [#if hasPhase2]
    for (int i = 0; i < jj_2_rtns.length; i++) jj_2_rtns[i] = new JJCalls();
        [/#if]
    [/#if]
  }
  [/#if]
[/#if]

[#if grammar.options.userDefinedLexer]
  /** Constructor with user supplied Lexer. */
  public ${grammar.parserClassName}(Lexer tm) {
[#else]
  /** Constructor with generated Token Manager. */
  public ${grammar.parserClassName}(${grammar.lexerClassName} tm) {
[/#if]
    token_source = tm;
    current_token = new Token();
[#if grammar.options.errorReporting]
    for (int i = 0; i < ${parserData.tokenMaskValues?size}; i++) jj_la1[i] = -1;
  [#if hasPhase2]
    for (int i = 0; i < jj_2_rtns.length; i++) jj_2_rtns[i] = new JJCalls();
  [/#if]
[/#if]
  }
  
  private Token consumeToken(int kind) throws ParseException {
    Token oldToken = current_token;
    if (current_token.next != null) current_token = current_token.next;
    else current_token = current_token.next = token_source.getNextToken();
    if (current_token.kind == kind) {
[#if grammar.options.errorReporting]
      jj_gen++;
    [#if hasPhase2]
      if (++jj_gc > 100) {
        jj_gc = 0;
        for (int i = 0; i < jj_2_rtns.length; i++) {
          JJCalls c = jj_2_rtns[i];
          while (c != null) {
            if (c.gen < jj_gen) c.first = null;
            c = c.next;
          }
        }
      }
    [/#if]
 [/#if]

[#if grammar.options.debugParser]
      trace_token(current_token, "");
[/#if]
[#if grammar.options.treeBuildingEnabled]
      if (buildTree && tokensAreNodes) {
  [#if grammar.options.userDefinedLexer]
          current_token.setInputSource(inputSource);
  [/#if]
  [#if grammar.usesjjtreeOpenNodeScope]
   	      jjtreeOpenNodeScope(current_token);
  [/#if]
  [#if grammar.usesOpenNodeScopeHook]
          openNodeScopeHook(current_token);
  [/#if]          
          pushNode(current_token);
  [#if grammar.usesjjtreeCloseNodeScope]
   	      jjtreeCloseNodeScope(current_token);
  [/#if]
  [#if grammar.usesCloseNodeScopeHook]
   	      closeNodeScopeHook(current_token);
  [/#if]
      }
[/#if]
      return current_token;
      
    }
    current_token = oldToken;

[#if grammar.getOptions().errorReporting]
    jj_kind = kind;
[/#if]
    throw generateParseException();
  }
  
[#if hasPhase2]
  @SuppressWarnings("serial")
  static private final class LookaheadSuccess extends java.lang.Error { }
  final private LookaheadSuccess ls = new LookaheadSuccess();
  private boolean jj_scan_token(int kind) {
    if (jj_scanpos == jj_lastpos) {
      jj_la--;
      if (jj_scanpos.next == null) {
        jj_lastpos = jj_scanpos = jj_scanpos.next = token_source.getNextToken();
      } else {
        jj_lastpos = jj_scanpos = jj_scanpos.next;
      }
    } else {
      jj_scanpos = jj_scanpos.next;
    }
   [#if grammar.options.errorReporting]
    if (rescan) {
      int i = 0; Token tok = current_token;
      while (tok != null && tok != jj_scanpos) { i++; tok = tok.next; }
      if (tok != null) jj_add_error_token(kind, i);
      [#if grammar.options.debugLookahead]
    } else {
      trace_scan(jj_scanpos, kind);
      [/#if]
    }
   [#elseif grammar.options.debugLookahead]
    trace_scan(jj_scanpos, kind);
   [/#if]
    if (jj_scanpos.kind != kind) return true;
    if (jj_la == 0 && jj_scanpos == jj_lastpos) throw ls;
    return false;
  }
[/#if]

/** Get the next Token. */
  final public Token getNextToken() {
    if (current_token.next != null) current_token = current_token.next;
    else current_token = current_token.next = token_source.getNextToken();
[#if grammar.options.errorReporting]
    jj_gen++;
[/#if]
[#if grammar.options.debugParser]
      trace_token(current_token, " (in getNextToken)");
[/#if]
    return current_token;
  }

/** Get the specific Token. */
  final public Token getToken(int index) {
[#if parserData.lookaheadNeeded]
    Token t = jj_lookingAhead ? jj_scanpos : current_token;
[#else]
    Token t = current_token;
[/#if]
    for (int i = 0; i < index; i++) {
      if (t.next != null) t = t.next;
      else t = t.next = token_source.getNextToken();
    }
    return t;
  }

  private int nextTokenKind() {
    if (current_token.next == null) {
        current_token.next = token_source.getNextToken();
    }
    return current_token.next.kind;
  }

[#if grammar.options.errorReporting]
  private java.util.ArrayList<int[]> jj_expentries = new java.util.ArrayList<int[]>();
  private int[] jj_expentry;
  private int jj_kind = -1;
  [#if hasPhase2]
  private int[] jj_lasttokens = new int[100];
  private int endPosition;
  
  private void jj_add_error_token(int kind, int pos) {
    if (pos >= 100) return;
    if (pos == endPosition + 1) {
      jj_lasttokens[endPosition++] = kind;
    } else if (endPosition != 0) {
      jj_expentry = new int[endPosition];
      for (int i = 0; i < endPosition; i++) {
        jj_expentry[i] = jj_lasttokens[i];
      }
      jj_entries_loop: for (java.util.Iterator<int[]> it = jj_expentries.iterator(); it.hasNext();) {
        int[] oldentry = (int[])(it.next());
        if (oldentry.length == jj_expentry.length) {
          for (int i = 0; i < jj_expentry.length; i++) {
            if (oldentry[i] != jj_expentry[i]) {
              continue jj_entries_loop;
            }
          }
          jj_expentries.add(jj_expentry);
          break jj_entries_loop;
        }
      }
      if (pos != 0) jj_lasttokens[(endPosition = pos) - 1] = kind;
    }
  }
  [/#if]

  public ParseException generateParseException() {
    jj_expentries.clear();
    boolean[] la1tokens = new boolean[${tokenCount}];
    if (jj_kind >= 0) {
      la1tokens[jj_kind] = true;
      jj_kind = -1;
    }
    for (int i = 0; i < ${parserData.tokenMaskValues?size}; i++) {
      if (jj_la1[i] == jj_gen) {
        for (int j = 0; j < 32; j++) {
   [#list 0..((tokenCount-1)/32) as i]
          if ((jj_la1_${i}[i] & (1<<j)) != 0) {
            la1tokens[${(32*i)}+j] = true;
          }
   [/#list]
        }
      }
    }
    for (int i = 0; i < ${tokenCount}; i++) {
      if (la1tokens[i]) {
        jj_expentry = new int[1];
        jj_expentry[0] = i;
        jj_expentries.add(jj_expentry);
      }
    }
   [#if hasPhase2]
    endPosition = 0;
    rescanToken();
    jj_add_error_token(0, 0);
   [/#if]
    int[][] exptokseq = new int[jj_expentries.size()][];
    for (int i = 0; i < jj_expentries.size(); i++) {
      exptokseq[i] = (int[])jj_expentries.get(i); 
    } 
    return new ParseException(current_token, exptokseq, tokenImage);
  }
  [#else]
  /** Generate ParseException. */
  public ParseException generateParseException() {
    Token errortok = current_token.next;
    int line = errortok.beginLine, column = errortok.beginColumn;
    String mess = (errortok.kind == 0) ? tokenImage[0] : errortok.image;
    return new ParseException("Parse error at line " + line + ", column " + column + ".  " +
               "Encountered: " + mess);
  }
  [/#if]

[#if grammar.options.debugParser]
  private int trace_indent = 0;
  private boolean trace_enabled = true;

/** Enable tracing. */
  final public void enable_tracing() {
    trace_enabled = true;
  }

/** Disable tracing. */
  final public void disable_tracing() {
    trace_enabled = false;
  }

  private void trace_call(String s) {
    if (trace_enabled) {
      for (int i = 0; i < trace_indent; i++) { System.out.print(" "); }
      System.out.println("Call:   " + s);
    }
    trace_indent = trace_indent + 2;
  }

  private void trace_return(String s) {
    trace_indent = trace_indent - 2;
    if (trace_enabled) {
      for (int i = 0; i < trace_indent; i++) { System.out.print(" "); }
      System.out.println("Return: " + s);
    }
  }

  private void trace_token(Token t, String where) {
    if (trace_enabled) {
      for (int i = 0; i < trace_indent; i++) { System.out.print(" "); }
      System.out.print("Consumed token: <" + tokenImage[t.kind]);
      if (t.kind != 0 && !tokenImage[t.kind].equals("\"" + t.image + "\"")) {
        System.out.print(": \"" + t.image + "\"");
      }
      System.out.println(" at line " + t.beginLine + 
                " column " + t.beginColumn + ">" + where);
    }
  }

  private void trace_scan(Token t1, int t2) {
    if (trace_enabled) {
      for (int i = 0; i < trace_indent; i++) { System.out.print(" "); }
      System.out.print("Visited token: <" + tokenImage[t1.kind]);
      if (t1.kind != 0 && !tokenImage[t1.kind].equals("\"" + t1.image + "\"")) {
        System.out.print(": \"" + t1.image + "\"");
      }
      System.out.println(" at line " + t1.beginLine + "" +
                " column " + t1.beginColumn + ">; Expected token: <" + nodeNames[t2] + ">");
    }
  }
[#else]
  /** Enable tracing. */
  final public void enable_tracing() {
  }

  /** Disable tracing. */
  final public void disable_tracing() {
  }

[/#if]

[#if hasPhase2&&grammar.options.errorReporting]
  private void rescanToken() {
    rescan = true;
    for (int i = 0; i < ${parserData.phase2Lookaheads?size}; i++) {
    try {
      JJCalls p = jj_2_rtns[i];
      do {
        if (p.gen > jj_gen) {
          jj_la = p.arg; jj_lastpos = jj_scanpos = p.first;
          switch (i) {
   [#list 0..(parserData.phase2Lookaheads?size-1) as i] 
            case ${i} : jj_3_${(i+1)}(); break;
   [/#list]
          }
        }
        p = p.next;
      } while (p != null);
      } catch(LookaheadSuccess ls) { }
    }
    rescan = false;
  }

  private void jj_save(int index, int xla) {
    JJCalls p = jj_2_rtns[index];
    while (p.gen > jj_gen) {
      if (p.next == null) { p = p.next = new JJCalls(); break; }
      p = p.next;
    }
    p.gen = jj_gen + xla - jj_la; p.first = current_token; p.arg = xla;
  }

[/#if]

[#if hasPhase2&&grammar.options.errorReporting]
  static final class JJCalls {
    int gen;
    Token first;
    int arg;
    JJCalls next;
  }
[/#if]


[#list grammar.BNFProductions as production]
  [#set currentProduction = production in javacode]
  [#if production.class.name?ends_with("ParserProduction")]
      [@javacode.JavaCodeProduction production/]
  [#else]
      [@javacode.BNFProduction production/]
  [/#if]
[/#list]

[#list parserData.phase2Lookaheads as lookahead]
   [@javacode.buildPhase2Routine lookahead.nestedExpansion/]
[/#list]


[#list parserData.phase3Table?keys as expansion]
   [@javacode.buildPhase3Routine expansion, parserData.getPhase3ExpansionCount(expansion)/]
[/#list]   
}
[#list grammar.otherParserCodeDeclarations as decl]
   ${decl}
[/#list]

