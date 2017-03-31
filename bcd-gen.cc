/*
 *  This is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This software is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "bcd-emul.hh"
#include <fstream>

using namespace std;

int main() {
	ofstream out("data/bcd-table.bin", ios::out|ios::binary);
	for (int ii = 0; ii < 256; ii++) {
		for (int jj = 0; jj < 256; jj++) {
			for (int cin = 0; cin < 2; cin++) {
				for (int zin = 0; zin < 2; zin++) {
					Context ctx(cin, zin);
					uint8_t rr = abcd(ctx, jj, ii);
					ctx.write(out);
					out.put(static_cast<char>(rr));
				}
			}
		}
	}
	for (int ii = 0; ii < 256; ii++) {
		for (int jj = 0; jj < 256; jj++) {
			for (int cin = 0; cin < 2; cin++) {
				for (int zin = 0; zin < 2; zin++) {
					Context ctx(cin, zin);
					uint8_t rr = sbcd(ctx, jj, ii);
					ctx.write(out);
					out.put(static_cast<char>(rr));
				}
			}
		}
	}
	for (int ii = 0; ii < 256; ii++) {
		for (int cin = 0; cin < 2; cin++) {
			for (int zin = 0; zin < 2; zin++) {
				Context ctx(cin, zin);
				uint8_t rr = nbcd(ctx, ii);
				ctx.write(out);
				out.put(static_cast<char>(rr));
			}
		}
	}
}

