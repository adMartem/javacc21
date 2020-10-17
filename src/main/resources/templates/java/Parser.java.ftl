[#ftl strict_vars=true]
[#--
/* Copyright (c) 2008-2020 Jonathan Revusky, revusky@javacc.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notices,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary format must reproduce the above copyright
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


[#var parserData=grammar.parserData]
[#var tokenCount=grammar.lexerData.tokenCount]

[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

[#if grammar.nodePackage?has_content && grammar.parserPackage! != grammar.nodePackage]
import ${grammar.nodePackage}.*;  
[/#if]
import java.util.*;
import java.util.concurrent.CancellationException;
import java.util.logging.*;
import java.io.*;
[#if grammar.parserPackage?has_content]
import static ${grammar.parserPackage}.${grammar.constantsClassName}.TokenType.*;
[/#if]

@SuppressWarnings("unused")
public class ${grammar.parserClassName} implements ${grammar.constantsClassName} {

    private static final java.util.logging.Logger LOGGER = Logger.getLogger(${grammar.parserClassName}.class.getName());
    
[#if grammar.options.debugParser]
     static {
         LOGGER.setLevel(Level.FINEST);
     }
[/#if]    

    public static void setLogLevel(Level level) {
        LOGGER.setLevel(level);
        Logger.getGlobal().getParent().getHandlers()[0].setLevel(level);
    }
static final int UNLIMITED = Integer.MAX_VALUE;    
// The last token successfully "consumed"     
Token currentToken;
private TokenType nextTokenType;
private Token currentLookaheadToken;
private int remainingLookahead;
private String currentlyParsedProduction, currentLookaheadProduction;
// private TokenType upToTokenType;
// private EnumSet<TokenType> upToFirstSet;
private boolean stopAtScanLimit;

private Token lastParsedToken;
//private Token nextToken; //REVISIT

//private EnumSet<Token> currentFollowSet;

private boolean cancelled;
public void cancel() {cancelled = true;}
public boolean isCancelled() {return cancelled;}
[#if grammar.options.userDefinedLexer]
  /** User defined Lexer. */
  public Lexer token_source;
  String inputSource = "input";
[#else]
  /** Generated Lexer. */
  public ${grammar.lexerClassName} token_source;
  
  public void setInputSource(String inputSource) {
      token_source.setInputSource(inputSource);
  }
  
[/#if]

  String getInputSource() {
      return token_source.getInputSource();
  }
  
 //=================================
 // Generated constructors
 //=================================

[#if !grammar.options.userDefinedLexer]
 [#if !grammar.options.hugeFileSupport]
   public ${grammar.parserClassName}(String inputSource, CharSequence content) {
       this(new ${grammar.lexerClassName}(inputSource, content));
      [#if grammar.options.lexerUsesParser]
      token_source.parser = this;
      [/#if]
  }

  public ${grammar.parserClassName}(CharSequence content) {
    this("input", content);
  }
 [/#if]
  public ${grammar.parserClassName}(java.io.InputStream stream) {
      this(new InputStreamReader(stream));
  }
  
  public ${grammar.parserClassName}(Reader reader) {
    this(new ${grammar.lexerClassName}(reader));
      [#if grammar.options.lexerUsesParser]
      token_source.parser = this;
      [/#if]
  }
[/#if]

[#if grammar.options.userDefinedLexer]
  /** Constructor with user supplied Lexer. */
  public ${grammar.parserClassName}(Lexer lexer) {
[#else]
  /** Constructor with user supplied Lexer. */
  public ${grammar.parserClassName}(${grammar.lexerClassName} lexer) {
[/#if]
    token_source = lexer;
      [#if grammar.options.lexerUsesParser]
      token_source.parser = this;
      [/#if]
     currentToken = new Token();
  }

  // If tok already has a next field set, it returns that
  // Otherwise, it goes to the token_source, i.e. the Lexer.
  final private Token nextToken(Token tok) {
    Token result = tok.getNext();
    if (result == null) {
      result = token_source.getNextToken();
      tok.setNext(result);
    }
[#list grammar.parserTokenHooks as methodName] 
    result = ${methodName}(result);
[/#list]
    tok.setNext(result);
    return result;
  }

  final public Token getNextToken() {
    return currentToken = getToken(1);
  }

/** Get the specific Token index ahead in the stream. */
  final public Token getToken(int index) {
    Token t = currentToken;
    for (int i = 0; i < index; i++) {
      t = nextToken(t);
    }
    return t;
  }

  private final TokenType nextTokenType() {
    this.nextTokenType = nextToken(currentToken).getType();
    return nextTokenType;
  }

  /**
   *Are we in the production of the given name, either scanning ahead or parsing?
   */
  private boolean isInProduction(String productionName) {
//    if (currentlyParsedProduction != null && currentlyParsedProduction.equals(productionName)) return true;
//    if (currentLookaheadProduction != null && currentLookaheadProduction.equals(productionName)) return true;
    Iterator<NonTerminalCall> it = stackIteratorBackward();
    while (it.hasNext()) {
      NonTerminalCall ntc = it.next();
      if (ntc.productionName.equals(productionName)) {
        return true;
      }
    }
    return false;
  }


[#import "ParserProductions.java.ftl" as ParserCode ]
[@ParserCode.Generate/]
 
[#embed "ErrorHandling.java.ftl"]

[#if grammar.options.treeBuildingEnabled]
   [#embed "TreeBuildingCode.java.ftl"]
[/#if]
}
  
}
[#list grammar.otherParserCodeDeclarations as decl]
//Generated from code on line ${decl.beginLine}, column ${decl.beginColumn} of ${decl.inputSource}
   ${decl}
[/#list]

