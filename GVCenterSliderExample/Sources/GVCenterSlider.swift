import UIKit

private let defaultThickness:CGFloat = 2.0

private let defaultThumbSize:CGFloat = 28.0
private let defaultCenterDotSize:CGFloat = 6.0

private let defaultSelectedColor:UIColor = UIColor.greenColor()
private let defaultUnselectedColor:UIColor = UIColor.lightGrayColor()

private let defaultMinValue:CGFloat = 0.0
private let defaultMaxValue:CGFloat = 1.0

private let defaultContinuous:Bool = true

@IBDesignable public class GVCenterSlider: UIControl {
    
    //it works like sending a message about changing value.
    public var actionBlock: ((slider: GVCenterSlider, value: CGFloat) -> Void)?
    
    //MARK: - Functions for override
    
    public func valueForEndedLocation(point: CGPoint, value: CGFloat) -> CGFloat {
        return value
    }
    
    //MARK: - Properties
    
    //IBInspectable
    @IBInspectable public var selectedColor: UIColor = defaultSelectedColor {
        didSet {
            _selectedTrackLayer.backgroundColor = self.selectedColor.CGColor
            _centerDotLayer.backgroundColor = self.selectedColor.CGColor
        }
    }
    
    @IBInspectable public var unselectedColor: UIColor = defaultUnselectedColor {
        didSet {
            _unselectedTrackLayer.backgroundColor = self.unselectedColor.CGColor
        }
    }
    
    @IBInspectable public var value: CGFloat {
        get{ return _value }
        set{ self.setValue(newValue, animated:true) }
    }
    
    public func setValue(value: CGFloat, animated: Bool = true) {
        _value = max(min(value, self.maximumValue), self.minimumValue)
        self.updateThumbPosition(animated: animated)
    }
    
    @IBInspectable public var minimumValue: CGFloat = defaultMinValue // default 0.0. the current value may change if outside new min value
    @IBInspectable public var maximumValue: CGFloat = defaultMaxValue // default 1.0. the current value may change if outside new max value
    
    @IBInspectable public var minimumValueImage: UIImage? = nil { // default is nil. image that appears to left of control (e.g. speaker off)
        didSet{
            if let img = self.minimumValueImage {
                let imgLayer = _minTrackImageLayer ?? {
                    let l = CALayer()
                    l.anchorPoint = CGPointMake(0.0, 0.5)
                    self.layer.addSublayer(l)
                    return l
                    }()
                imgLayer.contents = img.CGImage
                imgLayer.bounds = CGRectMake(0, 0, img.size.width, img.size.height)
                _minTrackImageLayer = imgLayer
                
            }else{
                _minTrackImageLayer?.removeFromSuperlayer()
                _minTrackImageLayer = nil
            }
            self.layer.needsLayout()
        }
    }
    @IBInspectable public var maximumValueImage: UIImage? = nil { // default is nil. image that appears to right of control (e.g. speaker max)
        didSet {
            if let img = self.maximumValueImage {
                let imgLayer = _maxTrackImageLayer ?? {
                    let l = CALayer()
                    l.anchorPoint = CGPointMake(1.0, 0.5)
                    self.layer.addSublayer(l)
                    return l
                    }()
                imgLayer.contents = img.CGImage
                imgLayer.bounds = CGRectMake(0, 0, img.size.width, img.size.height)
                _maxTrackImageLayer = imgLayer
                
            } else {
                _maxTrackImageLayer?.removeFromSuperlayer()
                _maxTrackImageLayer = nil
            }
            self.layer.needsLayout()
        }
    }
    
    // if set, value change events are generated any time the value changes due to dragging. default = YES
    @IBInspectable public var continuous: Bool = defaultContinuous
    
    @IBInspectable public var thickness: CGFloat = defaultThickness {
        didSet{
            _unselectedTrackLayer.cornerRadius = self.thickness / 2.0
            self.layer.setNeedsLayout()
        }
    }
    
    @IBInspectable public var thumbSize: CGFloat = defaultThumbSize {
        didSet {
            _thumbLayer.cornerRadius = self.thumbSize / 2.0
            _thumbLayer.bounds = CGRectMake(0, 0, self.thumbSize, self.thumbSize)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var centerDotSize: CGFloat = defaultCenterDotSize {
        didSet {
            _centerDotLayer.cornerRadius = self.centerDotSize / 2.0
            _centerDotLayer.bounds = CGRectMake(0, 0, self.centerDotSize, self.centerDotSize)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var thumbIcon: UIImage? = nil {
        didSet {
            _thumbIconLayer.contents = self.thumbIcon?.CGImage
        }
    }
    
    //just variables
    
    public var selectedBorderColor: UIColor? {
        set{
            _selectedTrackLayer.borderColor = newValue?.CGColor
        }
        get{
            if let color = _selectedTrackLayer.borderColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
    }
    
    public var selectedTrackBorderWidth: CGFloat {
        set {
            _selectedTrackLayer.borderWidth = newValue
        }
        get {
            return _selectedTrackLayer.borderWidth
        }
    }
    
    public var unselectedBorderColor: UIColor? {
        set{
            _unselectedTrackLayer.borderColor = newValue?.CGColor
        }
        get{
            if let color = _unselectedTrackLayer.borderColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
    }
    
    public var unselectedBorderWidth: CGFloat {
        set {
            _unselectedTrackLayer.borderWidth = newValue
        }
        get {
            return _unselectedTrackLayer.borderWidth
        }
    }
    
    public var thumbColor: UIColor {
        get {
            if let color = _thumbIconLayer.backgroundColor {
                return UIColor(CGColor: color)
            }
            return UIColor.whiteColor()
        }
        set {
            _thumbIconLayer.backgroundColor = newValue.CGColor
            self.thumbIcon = nil
        }
    }
    
    //MARK: - Private Properties
    
    private var _value: CGFloat = 0.0 // default 0.0. this value will be pinned to min/max
    
    private var _thumbLayer: CALayer = {
        let thumb = CALayer()
        thumb.cornerRadius = defaultThumbSize / 2.0
        thumb.bounds = CGRectMake(0, 0, defaultThumbSize, defaultThumbSize)
        thumb.backgroundColor = UIColor.whiteColor().CGColor
        thumb.shadowColor = UIColor.blackColor().CGColor
        thumb.shadowOffset = CGSizeMake(0.0, 2.5)
        thumb.shadowRadius = 2.0
        thumb.shadowOpacity = 0.25
        thumb.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.15).CGColor
        thumb.borderWidth = 0.5
        return thumb
    }()
    
    private var _centerDotLayer: CALayer = {
        let thumb = CALayer()
        thumb.cornerRadius = defaultCenterDotSize / 2.0
        thumb.bounds = CGRectMake(0, 0, defaultCenterDotSize, defaultCenterDotSize)
        thumb.backgroundColor = defaultSelectedColor.CGColor
        return thumb
    }()
    
    private var _selectedTrackLayer: CALayer = {
        let track = CALayer()
        track.cornerRadius = defaultThickness / 2.0
        track.borderColor = defaultSelectedColor.CGColor
        return track
    }()
    
    private var _unselectedTrackLayer: CALayer = {
        let track = CALayer()
        track.cornerRadius = defaultThickness / 2.0
        track.borderColor = defaultUnselectedColor.CGColor
        return track
    }()
    
    private var _minTrackImageLayer: CALayer? = nil
    private var _maxTrackImageLayer: CALayer? = nil
    
    private var _thumbIconLayer: CALayer = {
        let size = defaultThumbSize - 4
        let iconLayer = CALayer()
        iconLayer.cornerRadius = size / 2.0
        iconLayer.bounds = CGRectMake(0, 0, size, size)
        iconLayer.backgroundColor = UIColor.whiteColor().CGColor
        return iconLayer
    }()
    
    //MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.selectedColor = aDecoder.decodeObjectForKey("selectedColor") as? UIColor ?? defaultSelectedColor
        self.unselectedColor = aDecoder.decodeObjectForKey("unselectedColor") as? UIColor ?? defaultUnselectedColor
        
        self.value = aDecoder.decodeObjectForKey("value") as? CGFloat ?? defaultMinValue
        self.minimumValue = aDecoder.decodeObjectForKey("minimumValue") as? CGFloat ?? defaultMinValue
        self.maximumValue = aDecoder.decodeObjectForKey("maximumValue") as? CGFloat ?? defaultMaxValue
        
        self.minimumValueImage = aDecoder.decodeObjectForKey("minimumValueImage") as? UIImage
        self.maximumValueImage = aDecoder.decodeObjectForKey("maximumValueImage") as? UIImage
        
        self.continuous = aDecoder.decodeBoolForKey("continuous") ?? defaultContinuous
        
        self.thickness = aDecoder.decodeObjectForKey("thickness") as? CGFloat ?? defaultThickness
        
        self.thumbSize = aDecoder.decodeObjectForKey("thumbSize") as? CGFloat ?? defaultThumbSize
        self.centerDotSize = aDecoder.decodeObjectForKey("centerDotSize") as? CGFloat ?? defaultCenterDotSize
        
        self.thumbIcon = aDecoder.decodeObjectForKey("thumbIcon") as? UIImage
        
        self.commonSetup()
    }
    
    override public func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(self.selectedColor, forKey: "selectedColor")
        aCoder.encodeObject(self.unselectedColor, forKey: "unselectedColor")
        
        aCoder.encodeObject(self.value, forKey: "value")
        aCoder.encodeObject(self.minimumValue, forKey: "minimumValue")
        aCoder.encodeObject(self.maximumValue, forKey: "maximumValue")
        
        aCoder.encodeObject(self.minimumValueImage, forKey: "minimumValueImage")
        aCoder.encodeObject(self.maximumValueImage, forKey: "maximumValueImage")
        
        aCoder.encodeBool(self.continuous, forKey: "continuous")
        
        aCoder.encodeObject(self.thickness, forKey: "thickness")
        
        aCoder.encodeObject(self.thumbSize, forKey: "thumbSize")
        aCoder.encodeObject(self.centerDotSize, forKey: "centerDotSize")
        
        aCoder.encodeObject(self.thumbIcon, forKey: "thumbIcon")
    }
    
    private func commonSetup() {
        self.layer.delegate = self
        self.layer.addSublayer(_unselectedTrackLayer)
        self.layer.addSublayer(_selectedTrackLayer)
        self.layer.addSublayer(_centerDotLayer)
        self.layer.addSublayer(_thumbLayer)
        _thumbLayer.addSublayer(_thumbIconLayer)
    }
    
    //MARK: - Layout
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.thumbSize)
    }
    
    override public func alignmentRectInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(4.0, 2.0, 4.0, 2.0)
    }
    
    override public func layoutSublayersOfLayer(layer: CALayer) {
        //        super.layoutSublayersOfLayer(layer)
        
        if layer != self.layer {return}
        
        var w = self.bounds.width
        let h = self.bounds.height
        var left: CGFloat = 2.0
        
        if let minImgLayer = _minTrackImageLayer {
            minImgLayer.position = CGPointMake(0.0, h / 2.0)
            left = minImgLayer.bounds.width + 13.0
        }
        w -= left
        
        if let maxImgLayer = _maxTrackImageLayer {
            maxImgLayer.position = CGPointMake(self.bounds.width, h / 2.0)
            w -= (maxImgLayer.bounds.width + 13.0)
        } else {
            w -= 2.0
        }
        
        _unselectedTrackLayer.bounds = CGRectMake(0, 0, w, self.thickness)
        _unselectedTrackLayer.position = CGPointMake(w / 2.0 + left, h / 2.0)
        
        _centerDotLayer.position = _unselectedTrackLayer.position
        
        let halfSize = self.thumbSize / 2.0
        var layerSize = self.thumbSize - 4.0
        if let icon = self.thumbIcon {
            layerSize = min(max(icon.size.height,icon.size.width), layerSize)
            _thumbIconLayer.cornerRadius = 0.0
            _thumbIconLayer.backgroundColor = UIColor.clearColor().CGColor
        } else {
            _thumbIconLayer.cornerRadius = layerSize / 2.0
        }
        _thumbIconLayer.position = CGPointMake(halfSize, halfSize)
        _thumbIconLayer.bounds = CGRectMake(0, 0, layerSize, layerSize)
        
        self.updateThumbPosition(animated: false)
    }
    
    //MARK: - Touch Tracking
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let pt = touch.locationInView(self)
        
        let center = _thumbLayer.position
        let diameter = max(self.thumbSize, 44.0)
        let r = CGRectMake(center.x - diameter / 2.0, center.y - diameter / 2.0, diameter, diameter)
        if CGRectContainsPoint(r, pt) {
            self.sendActionsForControlEvents(UIControlEvents.TouchDown)
            return true
        }
        return false
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let pt = touch.locationInView(self)
        let newValue = self.calculateValueForLocation(pt)
        self.setValue(newValue, animated: false)
        if (self.continuous) {
            self.actionBlock?(slider: self, value: newValue)
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let pt = touch?.locationInView(self) {
            var newValue = self.calculateValueForLocation(pt)
            newValue = self.valueForEndedLocation(pt, value: newValue)
            self.setValue(newValue, animated: true)
        }
        self.actionBlock?(slider: self, value: _value)
        self.sendActionsForControlEvents([UIControlEvents.ValueChanged, UIControlEvents.TouchUpInside])
    }
    
    //MARK: - Private Functions
    
    private func calculateCurrentThumbPosition() -> CGPoint {
        let diff = self.maximumValue - self.minimumValue
        let perc = CGFloat((self.value - self.minimumValue) / diff)
        
        let halfHeight = self.bounds.height / 2.0
        let trackWidth = _unselectedTrackLayer.bounds.width - self.thumbSize
        let left = _unselectedTrackLayer.position.x - trackWidth / 2.0
        return CGPointMake(left + (trackWidth * perc), halfHeight)
    }
    
    private func updateThumbPosition(animated animated: Bool) {
        let position = self.calculateCurrentThumbPosition()
        
        if !animated {
            CATransaction.begin() //Move the thumb position without animations
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            _thumbLayer.position = position
            CATransaction.commit()
        } else {
            _thumbLayer.position = position
        }
        
        self.updateSelectedTrackPosition(animated: animated)
    }
    
    private func calculateValueForLocation(point: CGPoint) -> CGFloat {
        var left = self.bounds.origin.x
        var w = self.bounds.width
        if let minImgLayer = _minTrackImageLayer {
            let amt = minImgLayer.bounds.width + 13.0
            w -= amt
            left += amt
        } else {
            w -= 2.0
            left += 2.0
        }
        
        if let maxImgLayer = _maxTrackImageLayer {
            w -= (maxImgLayer.bounds.width + 13.0)
        } else {
            w -= 2.0
        }
        
        let diff = CGFloat(self.maximumValue - self.minimumValue)
        
        let perc = max(min((point.x - left) / w, 1.0), 0.0)
        
        return (perc * diff) + CGFloat(self.minimumValue)
    }
    
    private func updateSelectedTrackPosition(animated animated: Bool) {
        let thumbFrame = _thumbLayer.frame
        let halfWidthThumb = thumbFrame.size.width * 0.5
        let unselectedFrameCenter = _unselectedTrackLayer.position
        let diff = thumbFrame.origin.x - unselectedFrameCenter.x
        let unselectedFrame = _unselectedTrackLayer.frame
        var width: CGFloat = 0
        if self.value == self.minimumValue {
            width = diff
        } else if self.value == self.maximumValue {
            width = diff + halfWidthThumb * 2
        } else {
            width = diff + halfWidthThumb
        }
        let frame = CGRectMake(unselectedFrameCenter.x, unselectedFrame.origin.y, width, unselectedFrame.height)
        if !animated {
            CATransaction.begin() //Move the unselected layer without animations
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            _selectedTrackLayer.frame = frame
            CATransaction.commit()
        } else {
            _selectedTrackLayer.frame = frame
        }
    }
}



