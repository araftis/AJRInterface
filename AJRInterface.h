/*
 AJRInterface.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef __AJRInterface_h__
#define __AJRInterface_h__

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

#import <AJRInterface/AJRActivityToolbarProgressLayer.h>
#import <AJRInterface/AJRActivityToolbarView.h>
#import <AJRInterface/AJRActivityToolbarViewLayer.h>
#import <AJRInterface/AJRActivityView.h>
#import <AJRInterface/AJRActivityViewer.h>
#import <AJRInterface/AJRBMPImageFormat.h>
#import <AJRInterface/AJRBezelInBorder.h>
#import <AJRInterface/AJRBezelOutBorder.h>
#import <AJRInterface/AJRBorder.h>
#import <AJRInterface/AJRBorderInspector.h>
#import <AJRInterface/AJRBorderInspectorModule.h>
#import <AJRInterface/AJRBox.h>
#import <AJRInterface/AJRBoxController.h>
#import <AJRInterface/AJRBundleProtocol.h>
#import <AJRInterface/AJRButtonBar.h>
#import <AJRInterface/AJRCalendarDayRenderer.h>
#import <AJRInterface/AJRCalendarDateChooser.h>
#import <AJRInterface/AJRCalendarEvent.h>
#import <AJRInterface/AJRCalendarEventInspector.h>
#import <AJRInterface/AJRCalendarItemInspector.h>
#import <AJRInterface/AJRCalendarItemInspectorController.h>
#import <AJRInterface/AJRCalendarItemInspectorWindow.h>
#import <AJRInterface/AJRCalendarMonthRenderer.h>
#import <AJRInterface/AJRCalendarQuarterRenderer.h>
#import <AJRInterface/AJRCalendarRenderer.h>
#import <AJRInterface/AJRCalendarScroller.h>
#import <AJRInterface/AJRCalendarView.h>
#import <AJRInterface/AJRCalendarWeekRenderer.h>
#import <AJRInterface/AJRCalendarYearRenderer.h>
#import <AJRInterface/AJRCascadingWindowController.h>
#import <AJRInterface/AJRCenteringView.h>
#import <AJRInterface/AJRCIEColor.h>
#import <AJRInterface/AJRCollectionView.h>
#import <AJRInterface/AJRColorSwatchView.h>
#import <AJRInterface/AJRColorTransformer.h>
#import <AJRInterface/AJRColorWell.h>
#import <AJRInterface/AJRDropShadowBorder.h>
#import <AJRInterface/AJRDropShadowBorderInspectorModule.h>
#import <AJRInterface/AJRDropShadowRenderer.h>
#import <AJRInterface/AJRDropShadowRendererInspectorModule.h>
#import <AJRInterface/AJREmbossRenderer.h>
#import <AJRInterface/AJREmbossRendererInspectorModule.h>
#import <AJRInterface/AJRExceptionPanel.h>
#import <AJRInterface/AJRExpansionView.h>
#import <AJRInterface/AJRExpansionViewItem.h>
#import <AJRInterface/AJRFacingPageLayout.h>
#import <AJRInterface/AJRFadingWindowController.h>
#import <AJRInterface/AJRFill.h>
#import <AJRInterface/AJRFillInspector.h>
#import <AJRInterface/AJRFillInspectorModule.h>
#import <AJRInterface/AJRFillRenderer.h>
#import <AJRInterface/AJRFillRendererInspectorModule.h>
#import <AJRInterface/AJRFlippedView.h>
#import <AJRInterface/AJRFlippedCenteringView.h>
#import <AJRInterface/AJRGIFImageFormat.h>
#import <AJRInterface/AJRGradientColor.h>
#import <AJRInterface/AJRGradientFill.h>
#import <AJRInterface/AJRGradientFillInspectorModule.h>
#import <AJRInterface/AJRGrooveBorder.h>
#import <AJRInterface/AJRHUDTableView.h>
#import <AJRInterface/AJRHaloRenderer.h>
#import <AJRInterface/AJRHaloRendererInspectorModule.h>
#import <AJRInterface/AJRHistogramView.h>
#import <AJRInterface/AJRHorizontalPageLayout.h>
#import <AJRInterface/AJRImageCell.h>
#import <AJRInterface/AJRImageFormat.h>
#import <AJRInterface/AJRImageSaveAccessory.h>
#import <AJRInterface/AJRImages.h>
#import <AJRInterface/AJRInspector.h>
#import <AJRInterface/AJRInspectorModule.h>
#import <AJRInterface/AJRInspectable.h>
#import <AJRInterface/AJRInterfaceDefines.h>
#import <AJRInterface/AJRInterfaceFunctions.h>
#import <AJRInterface/AJRJPEGImageFormat.h>
#import <AJRInterface/AJRWindow.h>
#import <AJRInterface/AJRLabel.h>
#import <AJRInterface/AJRLabelCell.h>
#import <AJRInterface/AJRLineBorder.h>
#import <AJRInterface/AJRLineBorderInspectorModule.h>
#import <AJRInterface/AJRLineNumberMarker.h>
#import <AJRInterface/AJRLineNumberView.h>
#import <AJRInterface/AJRMultiViewController.h>
#import <AJRInterface/AJROptionalAlertPanel.h>
#import <AJRInterface/AJRPNGImageFormat.h>
#import <AJRInterface/AJRPagedScrollView.h>
#import <AJRInterface/AJRPagedView.h>
#import <AJRInterface/AJRPageLayout.h>
#import <AJRInterface/AJRPaper.h>
#import <AJRInterface/AJRPathRenderer.h>
#import <AJRInterface/AJRPathRendererInspector.h>
#import <AJRInterface/AJRPathRendererInspectorModule.h>
#import <AJRInterface/AJRPieChart.h>
#import <AJRInterface/AJRPipeBorder.h>
#import <AJRInterface/AJRPipeBorderInspectorModule.h>
#import <AJRInterface/AJRPopUpTextField.h>
#import <AJRInterface/AJRPopUpTextFieldCell.h>
#import <AJRInterface/AJRPreferences.h>
#import <AJRInterface/AJRPreferencesModule.h>
#import <AJRInterface/AJRProgressView.h>
#import <AJRInterface/AJRProView.h>
#import <AJRInterface/AJRRatingsCell.h>
#import <AJRInterface/AJRRatingsView.h>
#import <AJRInterface/AJRReport.h>
#import <AJRInterface/AJRReportAssign.h>
#import <AJRInterface/AJRReportConditional.h>
#import <AJRInterface/AJRReportElement.h>
#import <AJRInterface/AJRReportHistogram.h>
#import <AJRInterface/AJRReportImage.h>
#import <AJRInterface/AJRReportRepetition.h>
#import <AJRInterface/AJRReportString.h>
#import <AJRInterface/AJRReportView.h>
#import <AJRInterface/AJRRulerMarker.h>
#import <AJRInterface/AJRRulerView.h>
#import <AJRInterface/AJRRolodexBorder.h>
#import <AJRInterface/AJRScrollView.h>
#import <AJRInterface/AJRScrollViewAccessories.h>
#import <AJRInterface/AJRSectionView.h>
#import <AJRInterface/AJRSectionViewItem.h>
#import <AJRInterface/AJRSegmentedCell.h>
#import <AJRInterface/AJRSeparatorBorder.h>
#import <AJRInterface/AJRSolidFill.h>
#import <AJRInterface/AJRSolidFillInspectorModule.h>
#import <AJRInterface/AJRSourceIconCell.h>
#import <AJRInterface/AJRSourceOutlineView.h>
#import <AJRInterface/AJRSourceSplitView.h>
#import <AJRInterface/AJRSpeechBorder.h>
#import <AJRInterface/AJRSpiralBoundBorder.h>
#import <AJRInterface/AJRSpiralBoundBorderInspectorModule.h>
#import <AJRInterface/AJRSplitView.h>
#import <AJRInterface/AJRSplitViewBehavior.h>
#import <AJRInterface/AJRStrokeRenderer.h>
#import <AJRInterface/AJRStrokeRendererInspectorModule.h>
#import <AJRInterface/AJRSyntaxComponent.h>
#import <AJRInterface/AJRSyntaxDefinition.h>
#import <AJRInterface/AJRSyntaxTextStorage.h>
#import <AJRInterface/AJRTIFFImageFormat.h>
#import <AJRInterface/AJRTabViewController.h>
#import <AJRInterface/AJRTerritoryCanvas.h>
#import <AJRInterface/AJRTerritoryObject.h>
#import <AJRInterface/AJRTerritoryViewer.h>
#import <AJRInterface/AJRTexturedBezelBorder.h>
#import <AJRInterface/AJRTexturedBezelBorderInspectorModule.h>
#import <AJRInterface/AJRTimestampToDateTransformer.h>
#import <AJRInterface/AJRToggleButton.h>
#import <AJRInterface/AJRToggleButtonAnimation.h>
#import <AJRInterface/AJRToggleButtonCell.h>
#import <AJRInterface/AJRToolbarPopUpButton.h>
#import <AJRInterface/AJRToolbarPopUpButtonCell.h>
#import <AJRInterface/AJRTwoUpPageLayout.h>
#import <AJRInterface/AJRUIActivity.h>
#import <AJRInterface/AJRURLField.h>
#import <AJRInterface/AJRURLFieldCell.h>
#import <AJRInterface/AJRVerticalPageLayout.h>
#import <AJRInterface/AJRWebView.h>
#import <AJRInterface/AJRWellBorder.h>
#import <AJRInterface/AJRWhiteBox.h>
#import <AJRInterface/EKAlarm+Extensions.h>
#import <AJRInterface/EKEvent+Extensions.h>
#import <AJRInterface/EKParticipant+Extensions.h>
#import <AJRInterface/EKCalendar+Extensions.h>
#import <AJRInterface/EKRecurrenceRule+Extensions.h>
#import <AJRInterface/DOMNode+Extensions.h>
#import <AJRInterface/NSAffineTransform+Extensions.h>
#import <AJRInterface/NSAlert+Extensions.h>
#import <AJRInterface/NSApplication+Extensions.h>
#import <AJRInterface/NSArrayController+Extensions.h>
#import <AJRInterface/NSAttributedString+Extensions.h>
#import <AJRInterface/NSBezierPath+Extensions.h>
#import <AJRInterface/NSBitmapImageRep+Extensions.h>
#import <AJRInterface/NSBundle+Extensions.h>
#import <AJRInterface/NSColor+Extensions.h>
#import <AJRInterface/NSColorSpace+Extensions.h>
#import <AJRInterface/NSDictionary+Extensions.h>
#import <AJRInterface/NSEvent+Extensions.h>
#import <AJRInterface/NSGradient+Extensions.h>
#import <AJRInterface/NSGraphicsContext+Extensions.h>
#import <AJRInterface/NSImage+Extensions.h>
#import <AJRInterface/NSLayoutManager+Extensions.h>
#import <AJRInterface/NSMenu+Extensions.h>
#import <AJRInterface/NSMutableDictionary+Extensions.h>
#import <AJRInterface/NSOutlineView+Extensions.h>
#import <AJRInterface/NSPrinter+Extensions.h>
#import <AJRInterface/NSPrintInfo+Extensions.h>
#import <AJRInterface/NSSegmentedControl+Extensions.h>
#import <AJRInterface/NSString+Extensions.h>
#import <AJRInterface/NSTableView+Extensions.h>
#import <AJRInterface/NSTabView+Extensions.h>
#import <AJRInterface/NSTableView+Dragging.h>
#import <AJRInterface/NSTextFieldCell+Extensions.h>
#import <AJRInterface/NSTextView+Extensions.h>
#import <AJRInterface/NSToolbar+Extensions.h>
#import <AJRInterface/NSTreeController+Extensions.h>
#import <AJRInterface/NSUserDefaults+Extensions.h>
#import <AJRInterface/NSView+Extensions.h>
#import <AJRInterface/NSViewController+Extensions.h>
#import <AJRInterface/NSWindow+Extensions.h>
#import <AJRInterface/NSWorkspace+Extensions.h>

#endif
