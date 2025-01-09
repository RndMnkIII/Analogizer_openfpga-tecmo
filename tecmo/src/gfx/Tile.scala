/*
 *   __   __     __  __     __         __
 *  /\ "-.\ \   /\ \/\ \   /\ \       /\ \
 *  \ \ \-.  \  \ \ \_\ \  \ \ \____  \ \ \____
 *   \ \_\\"\_\  \ \_____\  \ \_____\  \ \_____\
 *    \/_/ \/_/   \/_____/   \/_____/   \/_____/
 *   ______     ______       __     ______     ______     ______
 *  /\  __ \   /\  == \     /\ \   /\  ___\   /\  ___\   /\__  _\
 *  \ \ \/\ \  \ \  __<    _\_\ \  \ \  __\   \ \ \____  \/_/\ \/
 *   \ \_____\  \ \_____\ /\_____\  \ \_____\  \ \_____\    \ \_\
 *    \/_____/   \/_____/ \/_____/   \/_____/   \/_____/     \/_/
 *
 * https://joshbassett.info
 * https://twitter.com/nullobject
 * https://github.com/nullobject
 *
 * Copyright (c) 2022 Josh Bassett
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package tecmo.gfx

import arcadia.Util
import chisel3._
import tecmo.Config

/** Represents a tile descriptor. */
class Tile extends Bundle {
  /** Color code */
  val colorCode = UInt(Config.PALETTE_WIDTH.W)
  /** Tile code */
  val code = UInt(Tile.CODE_WIDTH.W)
}

object Tile {
  /** The width of the tile code */
  val CODE_WIDTH = 11

  /**
   * Decodes a tile from the given data.
   *
   * {{{
   *  byte   bits       description
   * ------+-7654-3210-+-------------
   *     0 | xxxx xxxx | lo code
   *     1 | ---- -xxx | hi code
   *       | xxxx ---- | color
   * }}}
   *
   * @param data The tile data.
   */
  def decode(data: Bits): Tile = {
    val words = Util.decode(data, 2, 8)
    val tile = Wire(new Tile)
    tile.colorCode := words(1)(7, 4)
    tile.code := words(1)(2, 0) ## words(0)(7, 0)
    tile
  }

  /**
   * Decodes a Gemini Wing tile from the given data.
   *
   * {{{
   *  byte   bits       description
   * ------+-7654-3210-+-------------
   *     0 | xxxx xxxx | lo code
   *     1 | ---- xxxx | color
   *       | -xxx ---- | hi code
   * }}}
   *
   * @param data The tile data.
   */
  def decodeGemini(data: Bits): Tile = {
    val words = Util.decode(data, 2, 8)
    val tile = Wire(new Tile)
    tile.colorCode := words(1)(3, 0)
    tile.code := words(1)(6, 4) ## words(0)(7, 0)
    tile
  }
}
