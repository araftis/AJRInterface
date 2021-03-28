
import Cocoa

class AJRInspectorSliceDate: AJRInspectorSliceField {
    
    open var valueKey : AJRInspectorKey<Date>?
    open var formatKey : AJRInspectorKey<String>?
    open var dateFormatter = DateFormatter() {
        didSet {
            field?.formatter = dateFormatter
        }
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("format")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        formatKey = try AJRInspectorKey(key: "format", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["No Selection"]
                    strongSelf.field.isEditable = false
                case .multiple:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["Multiple Selection"]
                    strongSelf.field.isEditable = true
                case .single:
                    strongSelf.field.placeholderString = ""
                    if let value = strongSelf.valueKey?.value {
                        strongSelf.field.objectValue = value
                    } else {
                        strongSelf.field.stringValue = ""
                        if let nullPlaceholder = strongSelf.nullPlaceholder?.value {
                            strongSelf.field.placeholderString = nullPlaceholder
                        } else {
                            strongSelf.field.placeholderString = ""
                        }
                    }
                    strongSelf.field.isEditable = true
                }
            }
        }
        formatKey?.addObserver {
            if let strongSelf = weakSelf {
                let newFormatter = DateFormatter()
                newFormatter.dateFormat = strongSelf.formatKey?.value ?? "yyyy-MM-dd"
                strongSelf.dateFormatter = newFormatter
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction open override func takeValue(from sender: Any?) -> Void {
        if hasEdits, let sender = sender as? NSTextField {
            if let value = sender.objectValue as? Date {
                valueKey?.value = value
            } else if let value = sender.objectValue as? String {
                var dateValue : Date? = nil
                if let value = dateFormatter.date(from: value) {
                    dateValue = value
                } else if let value = try? AJRDateFromString(value, nil) {
                    dateValue = value
                }
                if let dateValue = dateValue {
                    valueKey?.value = dateValue
                } else {
                    valueKey?.value = nil
                }
            } else {
                valueKey?.value = nil
            }
        }
    }
    
}
