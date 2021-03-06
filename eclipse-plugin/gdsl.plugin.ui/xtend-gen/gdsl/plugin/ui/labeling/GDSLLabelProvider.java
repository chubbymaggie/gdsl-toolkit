package gdsl.plugin.ui.labeling;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import gdsl.plugin.gDSL.CONS;
import gdsl.plugin.gDSL.ConDecl;
import gdsl.plugin.gDSL.DeclExport;
import gdsl.plugin.gDSL.Ty;
import gdsl.plugin.gDSL.TyElement;
import gdsl.plugin.gDSL.Type;
import gdsl.plugin.gDSL.Val;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.eclipse.jdt.ui.ISharedImages;
import org.eclipse.jdt.ui.JavaUI;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.graphics.Image;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider;
import org.eclipse.xtext.xbase.lib.Conversions;

/**
 * Provides labels for a EObjects.
 * 
 * @author Daniel Endress
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#labelProvider
 */
@SuppressWarnings("all")
public class GDSLLabelProvider extends DefaultEObjectLabelProvider {
  @Inject
  public GDSLLabelProvider(final AdapterFactoryLabelProvider delegate) {
    super(delegate);
  }
  
  public String text(final DeclExport e) {
    Val _name = e.getName();
    return _name.getName();
  }
  
  public Image image(final DeclExport e) {
    ISharedImages _sharedImages = JavaUI.getSharedImages();
    return _sharedImages.getImage(ISharedImages.IMG_OBJS_PRIVATE);
  }
  
  public StyledString text(final Type t) {
    StyledString result = new StyledString();
    String _name = t.getName();
    result.append(_name);
    Ty _value = t.getValue();
    boolean _notEquals = (!Objects.equal(null, _value));
    if (_notEquals) {
      final StyledString.Styler style = StyledString.DECORATIONS_STYLER;
      Ty _value_1 = t.getValue();
      String _text = this.text(_value_1);
      String _plus = (" = " + _text);
      result.append(_plus, style);
    }
    return result;
  }
  
  public String text(final Ty t) {
    String _xblockexpression = null;
    {
      StringBuilder result = new StringBuilder();
      String _value = t.getValue();
      boolean _notEquals = (!Objects.equal(null, _value));
      if (_notEquals) {
        String _value_1 = t.getValue();
        result.append(_value_1);
      }
      Type _typeRef = t.getTypeRef();
      boolean _notEquals_1 = (!Objects.equal(null, _typeRef));
      if (_notEquals_1) {
        Type _typeRef_1 = t.getTypeRef();
        String _name = _typeRef_1.getName();
        result.append(_name);
      }
      String _type = t.getType();
      boolean _notEquals_2 = (!Objects.equal(null, _type));
      if (_notEquals_2) {
        String _type_1 = t.getType();
        result.append(_type_1);
      }
      boolean _and = false;
      EList<TyElement> _elements = t.getElements();
      boolean _notEquals_3 = (!Objects.equal(null, _elements));
      if (!_notEquals_3) {
        _and = false;
      } else {
        EList<TyElement> _elements_1 = t.getElements();
        int _length = ((Object[])Conversions.unwrapArray(_elements_1, Object.class)).length;
        boolean _greaterThan = (_length > 0);
        _and = _greaterThan;
      }
      if (_and) {
        result.append("{");
        EList<TyElement> _elements_2 = t.getElements();
        TyElement _get = _elements_2.get(0);
        String _name_1 = _get.getName();
        String _plus = (_name_1 + ":");
        EList<TyElement> _elements_3 = t.getElements();
        TyElement _get_1 = _elements_3.get(0);
        Ty _value_2 = _get_1.getValue();
        String _text = this.text(_value_2);
        String _plus_1 = (_plus + _text);
        result.append(_plus_1);
        int i = 1;
        EList<TyElement> _elements_4 = t.getElements();
        int _length_1 = ((Object[])Conversions.unwrapArray(_elements_4, Object.class)).length;
        boolean _lessThan = (i < _length_1);
        boolean _while = _lessThan;
        while (_while) {
          {
            EList<TyElement> _elements_5 = t.getElements();
            TyElement _get_2 = _elements_5.get(i);
            String _name_2 = _get_2.getName();
            String _plus_2 = (", " + _name_2);
            String _plus_3 = (_plus_2 + ":");
            EList<TyElement> _elements_6 = t.getElements();
            TyElement _get_3 = _elements_6.get(i);
            Ty _value_3 = _get_3.getValue();
            String _text_1 = this.text(_value_3);
            String _plus_4 = (_plus_3 + _text_1);
            result.append(_plus_4);
            i = (i + 1);
          }
          EList<TyElement> _elements_5 = t.getElements();
          int _length_2 = ((Object[])Conversions.unwrapArray(_elements_5, Object.class)).length;
          boolean _lessThan_1 = (i < _length_2);
          _while = _lessThan_1;
        }
        result.append("}");
      }
      _xblockexpression = result.toString();
    }
    return _xblockexpression;
  }
  
  public Image image(final Type t) {
    ISharedImages _sharedImages = JavaUI.getSharedImages();
    return _sharedImages.getImage(ISharedImages.IMG_OBJS_PROTECTED);
  }
  
  public StyledString text(final ConDecl cd) {
    final StyledString.Styler style = StyledString.COUNTER_STYLER;
    StyledString result = new StyledString();
    CONS _name = cd.getName();
    String _conName = _name.getConName();
    result.append(_conName);
    Ty _ty = cd.getTy();
    boolean _notEquals = (!Objects.equal(null, _ty));
    if (_notEquals) {
      Ty _ty_1 = cd.getTy();
      String _text = this.text(_ty_1);
      String _plus = (" (" + _text);
      String _plus_1 = (_plus + ")");
      result.append(_plus_1, style);
    }
    Type _containerOfType = EcoreUtil2.<Type>getContainerOfType(cd, Type.class);
    String _name_1 = _containerOfType.getName();
    String _plus_2 = (" : " + _name_1);
    result.append(_plus_2, style);
    return result;
  }
  
  public Image image(final ConDecl cd) {
    ISharedImages _sharedImages = JavaUI.getSharedImages();
    return _sharedImages.getImage(ISharedImages.IMG_OBJS_IMPDECL);
  }
  
  public StyledString text(final Val v) {
    StyledString result = new StyledString();
    String _name = v.getName();
    result.append(_name);
    final EList<String> decPat = v.getDecPat();
    boolean _and = false;
    boolean _notEquals = (!Objects.equal(null, decPat));
    if (!_notEquals) {
      _and = false;
    } else {
      int _length = ((Object[])Conversions.unwrapArray(decPat, Object.class)).length;
      boolean _greaterThan = (_length > 0);
      _and = _greaterThan;
    }
    if (_and) {
      StringBuilder bitPat = new StringBuilder();
      for (final String s : decPat) {
        bitPat.append((" " + s));
      }
      String _string = bitPat.toString();
      String _trim = _string.trim();
      String _plus = (" [" + _trim);
      String _plus_1 = (_plus + "]");
      result.append(_plus_1, StyledString.QUALIFIER_STYLER);
    }
    final EList<String> attr = v.getAttr();
    boolean _and_1 = false;
    boolean _notEquals_1 = (!Objects.equal(null, attr));
    if (!_notEquals_1) {
      _and_1 = false;
    } else {
      int _length_1 = ((Object[])Conversions.unwrapArray(attr, Object.class)).length;
      boolean _greaterThan_1 = (_length_1 > 0);
      _and_1 = _greaterThan_1;
    }
    if (_and_1) {
      final StyledString.Styler style = StyledString.COUNTER_STYLER;
      result.append(" (", style);
      String _get = attr.get(0);
      result.append(_get, style);
      int i = 1;
      int _length_2 = ((Object[])Conversions.unwrapArray(attr, Object.class)).length;
      boolean _lessThan = (i < _length_2);
      boolean _while = _lessThan;
      while (_while) {
        {
          String _get_1 = attr.get(i);
          String _plus_2 = (", " + _get_1);
          result.append(_plus_2, style);
          i = (i + 1);
        }
        int _length_3 = ((Object[])Conversions.unwrapArray(attr, Object.class)).length;
        boolean _lessThan_1 = (i < _length_3);
        _while = _lessThan_1;
      }
      result.append(")", style);
    }
    return result;
  }
  
  public Image image(final Val v) {
    ISharedImages _sharedImages = JavaUI.getSharedImages();
    return _sharedImages.getImage(ISharedImages.IMG_OBJS_PUBLIC);
  }
}
