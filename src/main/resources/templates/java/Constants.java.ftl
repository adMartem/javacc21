/* Generated by: ${generated_by}. Do not edit. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

/**
 * Token literal values and constants.
 */

public interface ${grammar.constantsClassName} {

[#if grammar.legacyAPI]
  int INVALID = ${grammar.lexerData.tokenCount}; // Used for Lexically invalid input
  [#list grammar.lexerData.regularExpressions as regexp]
  int ${regexp.label} = ${regexp.ordinal};
  [/#list]
[/#if]  
  public enum TokenType {
     [#list grammar.lexerData.regularExpressions as regexp]
     ${regexp.label},
     [/#list]
     INVALID
  }
  
[#if !grammar.userDefinedLexer]
  /**
   * Lexical States
   */
[#if grammar.legacyAPI]
 [#list grammar.lexerData.lexicalStates as lexicalState]
  int ${lexicalState.name} = ${lexicalState_index};
 [/#list]
[/#if]

  public enum LexicalState {
  [#list grammar.lexerData.lexicalStates as lexicalState]
     ${lexicalState.name},
  [/#list]
   }
[/#if]
   
String[] tokenImage = {
      "<EOF>",
    [#list grammar.allTokenProductions as tokenProduction]
      [#list tokenProduction.regexpSpecs as regexpSpec]
      [@output_regexp regexpSpec.regexp/][#rt]
      [#if tokenProduction_has_next || regexpSpec_has_next],[/#if][#lt]
      [/#list]
    [/#list]
  };
}

[#macro output_regexp regexp]
   [#if regexp.class.name?ends_with("StringLiteral")]
      "\"${grammar.utils.addEscapes(regexp.image)}\""   
   [#elseif regexp.label != ""]
      "<${regexp.label}>"
   [#else]
      "<token of kind ${regexp.ordinal}>"
   [/#if]
[/#macro]
