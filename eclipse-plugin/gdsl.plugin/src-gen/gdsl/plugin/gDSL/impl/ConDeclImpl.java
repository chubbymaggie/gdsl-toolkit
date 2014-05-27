/**
 */
package gdsl.plugin.gDSL.impl;

import gdsl.plugin.gDSL.ConDecl;
import gdsl.plugin.gDSL.GDSLPackage;
import gdsl.plugin.gDSL.Ty;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Con Decl</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * <ul>
 *   <li>{@link gdsl.plugin.gDSL.impl.ConDeclImpl#getName <em>Name</em>}</li>
 *   <li>{@link gdsl.plugin.gDSL.impl.ConDeclImpl#getTy <em>Ty</em>}</li>
 * </ul>
 * </p>
 *
 * @generated
 */
public class ConDeclImpl extends MinimalEObjectImpl.Container implements ConDecl
{
  /**
   * The default value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected static final String NAME_EDEFAULT = null;

  /**
   * The cached value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected String name = NAME_EDEFAULT;

  /**
   * The cached value of the '{@link #getTy() <em>Ty</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getTy()
   * @generated
   * @ordered
   */
  protected Ty ty;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected ConDeclImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return GDSLPackage.Literals.CON_DECL;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public String getName()
  {
    return name;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setName(String newName)
  {
    String oldName = name;
    name = newName;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, GDSLPackage.CON_DECL__NAME, oldName, name));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Ty getTy()
  {
    return ty;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetTy(Ty newTy, NotificationChain msgs)
  {
    Ty oldTy = ty;
    ty = newTy;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, GDSLPackage.CON_DECL__TY, oldTy, newTy);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setTy(Ty newTy)
  {
    if (newTy != ty)
    {
      NotificationChain msgs = null;
      if (ty != null)
        msgs = ((InternalEObject)ty).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - GDSLPackage.CON_DECL__TY, null, msgs);
      if (newTy != null)
        msgs = ((InternalEObject)newTy).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - GDSLPackage.CON_DECL__TY, null, msgs);
      msgs = basicSetTy(newTy, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, GDSLPackage.CON_DECL__TY, newTy, newTy));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs)
  {
    switch (featureID)
    {
      case GDSLPackage.CON_DECL__TY:
        return basicSetTy(null, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case GDSLPackage.CON_DECL__NAME:
        return getName();
      case GDSLPackage.CON_DECL__TY:
        return getTy();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case GDSLPackage.CON_DECL__NAME:
        setName((String)newValue);
        return;
      case GDSLPackage.CON_DECL__TY:
        setTy((Ty)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case GDSLPackage.CON_DECL__NAME:
        setName(NAME_EDEFAULT);
        return;
      case GDSLPackage.CON_DECL__TY:
        setTy((Ty)null);
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case GDSLPackage.CON_DECL__NAME:
        return NAME_EDEFAULT == null ? name != null : !NAME_EDEFAULT.equals(name);
      case GDSLPackage.CON_DECL__TY:
        return ty != null;
    }
    return super.eIsSet(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString()
  {
    if (eIsProxy()) return super.toString();

    StringBuffer result = new StringBuffer(super.toString());
    result.append(" (name: ");
    result.append(name);
    result.append(')');
    return result.toString();
  }

} //ConDeclImpl
