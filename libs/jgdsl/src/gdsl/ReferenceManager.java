package gdsl;

public class ReferenceManager {
  private long references = 0;
  
  private IReferable referable;
  
  public ReferenceManager (IReferable referable) {
    this.referable = referable;
  }
  
  public void ref() {
    this.references++;
  }
  
  public void unref() {
    this.references--;
    checkRef();
  }
  
  public void checkRef() {
    if(this.references == 0)
      referable.free();
  }
}
