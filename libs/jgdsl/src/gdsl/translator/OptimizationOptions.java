package gdsl.translator;

/**
 * This enum represents configuration flags for the optimization of
 * the RReil code during block translation.
 * 
 * @author Julian Kranz
 */
public enum OptimizationOptions {
  /**
   * This flag requires the semantics of original machine program
   * and the translated program to equal on the instruction level.
   */
  PRESERVE_EVERYWHERE(1),

  /**
   * This flag requires the semantics of original machine program
   * and the translated program to equal on the basic block level.
   */
  PRESERVE_BLOCK(2),

  /**
   * This flag requires the semantics of original machine program
   * and the translated program to equal in the context they occur
   * in only. This means that the translation maps the semantics of
   * the program as a whole correctly whereas parts of translated semantics
   * cannot be mapped to parts of the original machine program.
   */
  PRESERVE_CONTEXT(4),

  /**
   * This flag enables the liveness optimization.
   */
  LIVENESS(8),

  /**
   * This flag enables the forward propagation of constants and
   * simple expressions.
   */
  FSUBST(16);

  private int flag;

  private OptimizationOptions (int flag) {
    this.flag = flag;
  }
  
  /**
   * Get the Gdsl config for this flag; the integer is used to describe
   * the optimization configuration option on the Gdsl side.
   * 
   * @return the internal Gdsl config option
   */
  public int getFlag () {
    return flag;
  }
  
  public OptimizationConfig config() {
    return new OptimizationConfig(getFlag());
  }
  
  public OptimizationConfig and (OptimizationOptions option) {
    return config().and(option);
  }

  public OptimizationConfig andNot (OptimizationOptions option) {
    return config().andNot(option);
  }
}
