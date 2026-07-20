//
//  NSTableView+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/3/26.
//

import AppKit

public extension NSTableView {

    func selectNextRow() {
        let selectedRow = selectedRow
        let nextRow: Int

        if selectedRow == -1 {
            nextRow = 0
        } else {
            nextRow = min(selectedRow + 1, numberOfRows - 1)
        }

        guard nextRow >= 0 else { return }

        selectRowIndexes(IndexSet(integer: nextRow), byExtendingSelection: false)
        scrollRowToVisible(nextRow)
    }

    func selectPreviousRow() {
        let selectedRow = selectedRow
        let previousRow: Int

        if selectedRow == -1 {
            previousRow = numberOfRows - 1
        } else {
            previousRow = max(selectedRow - 1, 0)
        }

        guard previousRow >= 0 else { return }

        selectRowIndexes(IndexSet(integer: previousRow), byExtendingSelection: false)
        scrollRowToVisible(previousRow)
    }

}
