import { expect } from "chai";

export function shouldRender(): void {
  describe("Poem render requirements", function () {
    it("can parse tokenURI", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const uri = await this.poem.connect(this.signers.admin).tokenURI(0);
      expect(uri).to.match(/^data:application\/json;base64,/);
      const base64 = uri.split(",")[1];
      const json = JSON.parse(Buffer.from(base64, "base64").toString());
      expect(json.name).to.equal("Piece #0");
      expect(json.image).to.match(/^data:image\/svg\+xml;base64,/);
      const svg = Buffer.from(json.image.split(",")[1], "base64").toString();
      expect(svg).to.contain("<svg xmlns");
    });

    it("renders exact SVG expected for path");
  });
}
