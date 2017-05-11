//
//  NSLabel.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 3/7/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(macOS)
    import AppKit

    open class NSLabel: NSTextField {
        open var text: String {
            get {
                return stringValue
            }
            set {
                stringValue = newValue
            }
        }

        open var fontSize: CGFloat {
            get {
                return font?.pointSize ?? NSFont.systemFontSize()
            }
            set {
                if let font = font {
                    self.font = NSFont(name: font.fontName, size: newValue)
                } else {
                    self.font = NSFont.systemFont(ofSize: newValue)
                }
            }
        }

        public convenience init(text: String) {
            self.init()

            self.text = text
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)

            setup()
        }

        public override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)

            setup()
        }

        public init() {
            super.init(frame: .zero)

            setup()
        }

        private func setup() {
            isBezeled = false
            drawsBackground = false
            isEditable = false
            isSelectable = true
        }
    }
#endif
