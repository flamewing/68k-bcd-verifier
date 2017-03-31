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
#include <iomanip>
#include <cstdint>

using namespace std;

Context::Context(uint8_t _X, uint8_t _Z)
: X(_X != 0), N(0), Z(_Z != 0), V(0), C(_X != 0) {
}

bool Context::operator==(const Context& other) const {
	return X == other.X &&
	       N == other.N &&
	       Z == other.Z &&
	       V == other.V &&
	       C == other.C;
}
bool Context::operator!=(const Context& other) const {
	return !(*this == other);
}

void Context::write(std::ostream& out) const {
	uint8_t flags = (X << 4) | (N << 3) | (Z << 2) | (V << 1) | (C << 0);
	out.put(static_cast<char>(flags));
}

ostream& operator<<(ostream& out, const Context& ctx) {
	out << (ctx.X ? 'X' : 'x')
	    << (ctx.N ? 'N' : 'n')
	    << (ctx.Z ? 'Z' : 'z')
	    << (ctx.V ? 'V' : 'v')
	    << (ctx.C ? 'C' : 'c');
	return out;
}

uint8_t abcd(Context& ctx, uint8_t xx, uint8_t yy) {
	uint8_t ss = xx + yy + ctx.X;
	// Normal carry computation for addition:
	// (sm & dm) | (~rm & dm) | (sm & ~rm)
	uint8_t bc = ((xx & yy) | (~ss & xx) | (~ss & yy)) & 0x88;
	// Compute if we have a decimal carry in both nibbles.
	// Note: 0x66 is type "int", so the entire computation is
	// promoted to "int", which is why the "& 0x110" works.
	uint8_t dc = (((ss + 0x66) ^ ss) & 0x110) >> 1;
	uint8_t corf = (bc | dc) - ((bc | dc) >> 2);
	uint8_t rr = ss + corf;
	// Compute flags.
	// Carry has two parts: normal carry for addition
	// (computed above) OR'ed with normal carry for
	// addition with corf:
	// (sm & dm) | (~rm & dm) | (sm & ~rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.X = ctx.C = (bc | (ss & ~rr)) >> 7;
	// Normal overflow computation for addition with corf:
	// (sm & dm & ~rm) | (~sm & ~dm & rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.V = (~ss & rr) >> 7;
	// Accumulate zero flag:
	ctx.Z = ctx.Z & (rr == 0);
	ctx.N = rr >> 7;
	return rr;
}

uint8_t sbcd(Context& ctx, uint8_t xx, uint8_t yy) {
	uint8_t dd = xx - yy - ctx.X;
	// Normal carry computation for subtraction:
	// (sm & ~dm) | (rm & ~dm) | (sm & rm)
	uint8_t bc = ((~xx & yy) | (dd & ~xx) | (dd & yy)) & 0x88;
	uint8_t corf = bc - (bc >> 2);
	uint8_t rr = dd - corf;
	// Compute flags.
	// Carry has two parts: normal carry for subtraction
	// (computed above) OR'ed with normal carry for
	// subtraction with corf:
	// (sm & ~dm) | (rm & ~dm) | (sm & rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.X = ctx.C = (bc | (~dd & rr)) >> 7;
	// Normal overflow computation for subtraction with corf:
	// (~sm & dm & ~rm) | (sm & ~dm & rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.V = (dd & ~rr) >> 7;
	// Accumulate zero flag:
	ctx.Z = ctx.Z & (rr == 0);
	ctx.N = rr >> 7;
	return rr;
}

uint8_t nbcd(Context& ctx, uint8_t xx) {
	// Equivalent to
	//return sbcd(ctx, 0, xx);
	// but slightly optimized.
	uint8_t dd = - xx - ctx.X;
	// Normal carry computation for subtraction:
	// (sm & ~dm) | (rm & ~dm) | (sm & rm)
	// but simplified because dm = 0 and ~dm = 1 for 0:
	uint8_t bc = (xx | dd) & 0x88;
	uint8_t corf = bc - (bc >> 2);
	uint8_t rr = dd - corf;
	// Compute flags.
	// Carry has two parts: normal carry for subtraction
	// (computed above) OR'ed with normal carry for
	// subtraction with corf:
	// (sm & ~dm) | (rm & ~dm) | (sm & rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.X = ctx.C = (bc | (~dd & rr)) >> 7;
	// Normal overflow computation for subtraction with corf:
	// (~sm & dm & ~rm) | (sm & ~dm & rm)
	// but simplified because sm = 0 and ~sm = 1 for corf:
	ctx.V = (dd & ~rr) >> 7;
	// Accumulate zero flag:
	ctx.Z = ctx.Z & (rr == 0);
	ctx.N = rr >> 7;
	return rr;
}

